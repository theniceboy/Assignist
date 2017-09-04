//
//  frmAssignmentList_NewAssignment_NewSubject.swift
//  Assignments
//
//  Created by David Chen on 9/3/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import RandomColor

class frmAssignmentList_NewAssignment_NewSubject: UIViewController {
    
    @IBOutlet weak var tfName: SkyFloatingLabelTextField!
    @IBOutlet weak var btnAdd: ZFRippleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curFrmAssignmentList_NewAssignment_NewSubject = self
        
        initializeUI()
    }
    
    func initializeUI () {
        
        tfName.text = ""
        tfName.errorMessage = ""
        
        tfName.becomeFirstResponder()
    }

    @IBAction func tfName_EditingChanged(_ sender: Any) {
        if (tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            tfName.errorMessage = ""
        }
    }
    
    @IBAction func btnCancel_Tapped(_ sender: Any) {
        self.dismiss(animated: true) { }
    }
    
    @IBAction func btnAdd_Tapped(_ sender: Any) {
        let name = (tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        if (name == "") {
            tfName.errorMessage = "The name of the subject cannot be empty"
        } else {
            var newSubjectItem: SubjectItem = SubjectItem()
            newSubjectItem.name = name
            newSubjectItem.color = UIColor(cgColor: randomColor(hue: Hue.random, luminosity: Luminosity.light).cgColor)
            subjectList.append(newSubjectItem)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addedSubject"), object: nil)
            saveSubjectList()
            self.dismiss(animated: true, completion: {
            })
        }
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
