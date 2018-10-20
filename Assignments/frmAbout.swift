//
//  frmAbout.swift
//  Assignments
//
//  Created by David Chen on 9/11/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import MessageUI

class frmAbout: UIViewController, MFMailComposeViewControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var vShareSourceFrame: UIView!
    
    // MARK: - Actions
    
    @IBAction func btnClose_Tapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnShare_Tapped(_ sender: Any) {
        if let name = URL(string: "https://itunes.apple.com/app/apple-store/id1281376562") {
            let activityController = UIActivityViewController(activityItems: [name], applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = vShareSourceFrame
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnEmail_Tapped(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["assignment.app.feedback@gmail.com"])
            mail.setSubject("Assignist App Feedback")
            mail.setMessageBody("", isHTML: true)
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Unable to Send Email?", message: "Your email is not configured.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnGithub_Tapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://github.com/theniceboy/Assignments")!)
    }
    
    @IBAction func btnVisitDeveloperWebsite_Tapped(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://cwsoft.net")!)
    }
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

}
