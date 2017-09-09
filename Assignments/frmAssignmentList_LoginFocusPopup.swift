//
//  ViewController.swift
//  Assignments
//
//  Created by David Chen on 9/8/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

func syncAssignmentListWithFocus () {
    let request = URLRequest(url: URL(string: "https://focus.mvcs.org/focus")!)
    curFrmAssignmentList.webView.loadRequest(request)
    
    Drop.down("Logging In To Focus... (It would take a while...)", state: .info, duration: 5) {
    }
    curFrmAssignmentList.activityStart()
    
    let when = DispatchTime.now() + 40
    DispatchQueue.main.asyncAfter(deadline: when) {
        curFrmAssignmentList.LoginOvertime()
    }
}

class frmAssignmentList_LoginFocusPopup: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var lbHeader: UILabel!
    @IBOutlet weak var tfUsername: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var btnLogin: ZFRippleButton!
    
    // MARK: - Actions
    
    @IBAction func btnLogin_Tapped(_ sender: Any) {
        userSettings.focusUsername = (tfUsername.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        userSettings.focusPassword = (tfPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        saveUserSettings()
        
        syncAssignmentListWithFocus()
        
        self.dismiss(animated: true) {
        }
    }
    
    // MARK: - System functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curFrmAssignmentList_LoginFocusPopup = self

        self.preferredContentSize = CGSize(width: 375, height: 335)
        
        btnLogin.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
