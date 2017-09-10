//
//  frmAssignmentList_EditSubject.swift
//  Assignments
//
//  Created by David Chen on 9/9/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

var _EDIT_SUBJECT_ROW = 0

class frmAssignmentList_EditSubject: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var vTopBar: UIView!
    @IBOutlet weak var tfName: SkyFloatingLabelTextField!
    @IBOutlet weak var btnChangeColor: ZFRippleButton!
    @IBOutlet weak var btnResetColor: ZFRippleButton!
    
    // MARK: - Variables
    
    var curSubject: SubjectItem = SubjectItem()
    var tmpColor: UIColor = UIColor()
    
    // MARK: - Actions
    
    @IBAction func btnCancel_Tapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnDone_Tapped(_ sender: Any) {
        let name = (tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        if (name == "") {
            tfName.errorMessage = "The name of the subject cannot be empty"
            return
        }
        for item in subjectList {
            if (name == item.name && item.name != curSubject.name) {
                tfName.errorMessage = "The subject \"" + name + "\" already exists"
                return
            }
        }
        if (assignmentList.count > 0) {
            for i in 0 ... (assignmentList.count - 1) {
                if (assignmentList[i].subject == curSubject.name) {
                    assignmentList[i].subject = name
                }
            }
        }
        subjectList[_EDIT_SUBJECT_ROW - 1].color = tmpColor
        subjectList[_EDIT_SUBJECT_ROW - 1].name = name
        saveAssignmentList()
        saveSubjectList()
        curFrmAssignmentList.refreshTableAssignmentList()
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnChangeColor_Tapped(_ sender: Any) {
        tmpColor = newSubjectColor()
        vTopBar.backgroundColor = tmpColor
    }
    
    @IBAction func btnResetColor_Tapped(_ sender: Any) {
        vTopBar.backgroundColor = subjectList[_EDIT_SUBJECT_ROW - 1].color
    }
    
    // MARK: - System Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curSubject = subjectList[_EDIT_SUBJECT_ROW - 1]
        vTopBar.backgroundColor = curSubject.color
        tmpColor = curSubject.color
        tfName.text = curSubject.name
        
        //btnChangeColor.layer.borderColor = themeColor.cgColor
        //btnChangeColor.layer.borderWidth = 1.5
        btnChangeColor.layer.cornerRadius = 8
        
        btnResetColor.layer.cornerRadius = 8
    }

}
