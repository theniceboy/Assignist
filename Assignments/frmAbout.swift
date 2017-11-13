//
//  frmAbout.swift
//  Assignments
//
//  Created by David Chen on 9/11/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

class frmAbout: UIViewController {

    // MARK: - Outlets
    
    // MARK: - Actions
    
    @IBAction func btnClose_Tapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnGithub_Tapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://github.com/theniceboy/Assignments")!)
    }
    
    @IBAction func btnVisitDeveloperWebsite_Tapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://cwsoft.cc")!)
    }
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

}
