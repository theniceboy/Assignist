//
//  frmSettings.swift
//  Assignments
//
//  Created by David Chen on 9/10/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

var loginFromSettigns: Bool = false

class frmSettings: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var vFocus: UIView!
    
    // MARK: From vFocus
    
    @IBOutlet weak var tfUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var btnLoginFocus: ZFRippleButton!
    @IBOutlet weak var btnLogoutFocus: ZFRippleButton!
    
    @IBOutlet weak var _layout_vLogoutFocus: NSLayoutConstraint!
    
    // MARK: - Variables
    
    var showOvertime: Bool = false
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curFrmSettings = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.btnBackground_Tapped(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // For vFocus
        btnLoginFocus.layer.cornerRadius = 8
        btnLogoutFocus.layer.cornerRadius = 8
        
        if (loggedInFocus) {
            showLogoutButton()
        } else {
            hideLogoutButton()
        }
    }
    
    // MARK: - Universal
    
    @IBAction func btnDone_Tapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
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
        
        let request = URLRequest(url: URL(string: "https://focus.mvcs.org/focus")!)
        curFrmAssignmentList.webView.loadHTMLString("", baseURL: URL(string: "about:blank")!)
        curFrmAssignmentList.webView.loadRequest(URLRequest(url: URL(string: "about:blank")!))
        curFrmAssignmentList.webView.reload()
        print("im good here")
        curFrmAssignmentList.webView.stringByEvaluatingJavaScript(from: "document.getElementById('username-input').value='" + userSettings.focusUsername + "';document.getElementsByName('password')[0].value='" + userSettings.focusPassword + "';document.getElementsByClassName('form-button')[0].click()")
        print("still good")
        curFrmAssignmentList.webView.loadRequest(request)
        
        curFrmAssignmentList.invalidLoginInfoCount = 0
        curFrmAssignmentList.timerStart()
        
        let when = DispatchTime.now() + 30
        DispatchQueue.main.asyncAfter(deadline: when) {
            if (!loggedInFocus && !curFrmAssignmentList.webView.isLoading && self.showOvertime) {
                SwiftSpinner.sharedInstance.innerColor = UIColor.white
                SwiftSpinner.sharedInstance.outerColor = UIColor.yellow.withAlphaComponent(0.5)
                SwiftSpinner.show(duration: 2.0, title: "Connection Overtime, Try Again Later", animated: false)
            }
        }
    }
    
    func logoutFocus () {
        curFrmAssignmentList.webView.loadHTMLString("", baseURL: URL(string: "about:blank")!)
        curFrmAssignmentList.webView.loadRequest(URLRequest(url: URL(string: "about:blank")!))
        curFrmAssignmentList.webView.reload()
        curFrmAssignmentList.activityStop()
        
        tfUsername.text = ""
        tfPassword.text = ""
        
        userSettings.focusUsername = ""
        userSettings.focusPassword = ""
        loggedInFocus = false
        showOvertime = false
        saveUserSettings()
        var tmpAssignmentList: [AssignmentItem] = []
        for i in 0 ... (assignmentList.count - 1) {
            if (!assignmentList[i].fromFocus) {
                tmpAssignmentList.append(assignmentList[i])
            }
        }
        assignmentList = tmpAssignmentList
        var tmpflag = true
        for item in UIApplication.shared.scheduledLocalNotifications! {
            tmpflag = true
            for i in 0 ... (assignmentList.count - 1) {
                if (item.userInfo!["id"] as! Int == assignmentList[i].id) {
                    tmpflag = false
                }
            }
            if (tmpflag) {
                UIApplication.shared.cancelLocalNotification(item)
            }
        }
        
        var tmpSubjectList: [SubjectItem] = [], tmpFlag: Bool = false
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
        subjectList = tmpSubjectList
        
        saveAssignmentList()
        saveSubjectList()
        curFrmAssignmentList.refreshTableAssignmentList()
        
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
    }
    
    func hideLogoutButton () {
        UIView.animate(withDuration: 0.3) {
            self._layout_vLogoutFocus.constant = self.vFocus.frame.height
            self.view.layoutIfNeeded()
        }
    }
}
