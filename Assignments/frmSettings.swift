//
//  frmSettings.swift
//  Assignments
//
//  Created by David Chen on 9/10/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

var loginFromSettigns: Bool = false
var connectingFocusInProgress: Bool = false // to prevent showing "connection time out" after logging out from Focus

class frmSettings: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var btnStNotifications: UIButton!
    @IBOutlet weak var btnStFocus: UIButton!
    
    @IBOutlet weak var vNotificationSettings: UIView!
    @IBOutlet weak var vFocus: UIView!
    
    // MARK: From vFocus
    
    @IBOutlet weak var tfUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var btnLoginFocus: ZFRippleButton!
    @IBOutlet weak var btnLogoutFocus: ZFRippleButton!
    
    @IBOutlet weak var _layout_vLogoutFocus: NSLayoutConstraint!
    
    // MARK: from vNotifications
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    // MARK: - Variables
    
    var showOvertime: Bool = false
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curFrmSettings = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.btnBackground_Tapped(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // For vNotifications
        
        let defaultDate = Date(year: 1991, month: 12, day: 27, hour: userSettings.defaultPushNotificationTime_hour, minute: userSettings.defaultPushNotificationTime_minute, second: 0)
        timePicker.setDate(defaultDate, animated: false)
        
        // For vFocus
        btnLoginFocus.layer.cornerRadius = 8
        btnLogoutFocus.layer.cornerRadius = 8
        
        if (loggedInFocus) {
            showLogoutButton()
        } else {
            hideLogoutButton()
        }
        
        btnStFocus_Tapped(self)
    }
    
    // MARK: - Universal
    
    @IBAction func btnDone_Tapped(_ sender: Any) {
        for item in UIApplication.shared.scheduledLocalNotifications! {
            if (item.fireDate?.hour == userSettings.defaultPushNotificationTime_hour && item.fireDate?.minute == userSettings.defaultPushNotificationTime_minute) {
                item.fireDate = Date(year: (item.fireDate?.year)!, month: (item.fireDate?.month)!, day: (item.fireDate?.day)!, hour: timePicker.date.hour, minute: timePicker.date.minute, second: 0)
            }
        }
        userSettings.defaultPushNotificationTime_hour = timePicker.date.hour
        userSettings.defaultPushNotificationTime_minute = timePicker.date.minute
        saveUserSettings()
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnStNotification_Tapped(_ sender: Any) {
        vNotificationSettings.isHidden = false
        vFocus.isHidden = true
        
        btnStNotifications.backgroundColor = UIColor.white
        btnStFocus.backgroundColor = UIColor.groupTableViewBackground
    }
    
    @IBAction func btnStFocus_Tapped(_ sender: Any) {
        vNotificationSettings.isHidden = true
        vFocus.isHidden = false
        
        btnStNotifications.backgroundColor = UIColor.groupTableViewBackground
        btnStFocus.backgroundColor = UIColor.white
    }
    
    // MARK: - From vNotifications
    
    @IBAction func timePicker_ValueChanged(_ sender: Any) {
    }
    
    // MARK: - From vFocus
    
    @IBAction func btnBackground_Tapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func btnLoginFocus_Tapped(_ sender: Any) {
        let username = (tfUsername.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let password = (tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        if (username == "" || password == "") {
            if (username == "") {
                tfUsername.errorMessage = "Username cannot be empty"
            }
            if (password == "") {
                tfPassword.errorMessage = "Password cannot be empty"
            }
            return
        }
        
        self.view.endEditing(true)
        showOvertime = true
        
        tfUsername.errorMessage = ""
        tfPassword.errorMessage = ""
        
        loginFromSettigns = true
        SwiftSpinner.sharedInstance.innerColor = UIColor.white
        SwiftSpinner.sharedInstance.outerColor = UIColor.white
        SwiftSpinner.show("Connecting To Focus", animated: true)
        
        
        userSettings.focusUsername = username
        userSettings.focusPassword = password
        
        //curFrmAssignmentList.webView = UIWebView()
        let request = URLRequest(url: URL(string: "https://focus.mvcs.org/focus")!)//, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 100.0)
        curFrmAssignmentList.webView.loadHTMLString("", baseURL: URL(string: "about:blank")!)
        curFrmAssignmentList.webView.loadRequest(URLRequest(url: URL(string: "about:blank")!))
        curFrmAssignmentList.webView.reload()
        curFrmAssignmentList.webView.stringByEvaluatingJavaScript(from: "document.getElementById('username-input').value='" + username + "';document.getElementsByName('password')[0].value='" + password + "';document.getElementsByClassName('form-button')[0].click()")
        curFrmAssignmentList.webView.loadRequest(request)
        
        curFrmAssignmentList.invalidLoginInfoCount = 0
        curFrmAssignmentList.timerStart()
        connectingFocusInProgress = true
        
        let when = DispatchTime.now() + 50
        DispatchQueue.main.asyncAfter(deadline: when) {
            if (!loggedInFocus && self.showOvertime && connectingFocusInProgress) {
                SwiftSpinner.sharedInstance.innerColor = UIColor.white
                SwiftSpinner.sharedInstance.outerColor = UIColor.yellow.withAlphaComponent(0.5)
                SwiftSpinner.show(duration: 2.0, title: "Connection Timeout, Try Again Later", animated: false)
                connectingFocusInProgress = false
            }
        }
    }
    
    func logoutFocus () {
        curFrmAssignmentList.webView.loadRequest(URLRequest(url: URL(string: "https://focus.mvcs.org/focus/index.php?logout")!))
        curFrmAssignmentList.activityStop()
        
        tfUsername.text = ""
        tfPassword.text = ""
        
        userSettings.focusUsername = ""
        userSettings.focusPassword = ""
        loggedInFocus = false
        showOvertime = false
        saveUserSettings()
        var tmpAssignmentList: [AssignmentItem] = []
        if (assignmentList.count > 0) {
            for i in 0 ... (assignmentList.count - 1) {
                if (!assignmentList[i].fromFocus) {
                    tmpAssignmentList.append(assignmentList[i])
                }
            }
        }
        assignmentList = tmpAssignmentList
        var tmpflag = true
        for item in UIApplication.shared.scheduledLocalNotifications! {
            tmpflag = true
            for assignmentitem in assignmentList {
                if (item.userInfo!["id"] as! Int == assignmentitem.id) {
                    tmpflag = false
                }
            }
            if (tmpflag) {
                UIApplication.shared.cancelLocalNotification(item)
            }
        }
        
        var tmpSubjectList: [SubjectItem] = [], tmpFlag: Bool = false
        if (subjectList.count > 0) {
            for i in 0 ... (subjectList.count - 1) {
                tmpFlag = false
                if (assignmentList.count > 0) {
                    for j in 0 ... (assignmentList.count - 1) {
                        if (subjectList[i].name == tmpAssignmentList[j].subject) {
                            tmpFlag = true
                        }
                    }
                }
                if (tmpFlag || !subjectList[i].fromFocus) {
                    tmpSubjectList.append(subjectList[i])
                }
            }
        }
        subjectList = tmpSubjectList
        
        saveAssignmentList()
        saveSubjectList()
        curFrmAssignmentList.refreshTableAssignmentList()
        
        connectingFocusInProgress = false
        SwiftSpinner.show(duration: 1.5, title: "Logout Completed", animated: false)
        
        hideLogoutButton()
    }
    
    @IBAction func btnLogoutFocus_Tapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are You Sure You Want to Log Out?", message: "All of the assignments that were synced from MVCS Focus will be deleted!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) in
            self.logoutFocus()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLogoutButton () {
        UIView.animate(withDuration: 0.3) {
            self._layout_vLogoutFocus.constant = 0
            self.view.layoutIfNeeded()
        }
        self.dismiss(animated: true) {
        }
    }
    
    func hideLogoutButton () {
        UIView.animate(withDuration: 0.3) {
            self._layout_vLogoutFocus.constant = self.vFocus.frame.height
            self.view.layoutIfNeeded()
        }
    }
}
