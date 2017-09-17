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
    @IBOutlet weak var vNameBlocker: UIView!
    @IBOutlet weak var btnChangeColor: ZFRippleButton!
    @IBOutlet weak var btnResetColor: ZFRippleButton!
    @IBOutlet weak var btnDeleteSubject: ZFRippleButton!
    
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
    
    @IBAction func btnDeleteSubject_Tapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are You Sure You Want to Delete This Subject?", message: "This will also delete all of the assignments under this subject.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) in
            self.deleteSubject()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - System Functions
    
    func deleteSubject () {
        for i in 0 ... (subjectList.count - 1) {
            if (subjectList[i].name == subjectList[_EDIT_SUBJECT_ROW - 1].name) {
                if (assignmentList.count > 0) {
                    var j = 0
                    while (j < assignmentList.count) {
                        if (assignmentList[j].subject == subjectList[i].name) {
                            assignmentList.remove(at: j)
                            j -= 1
                        }
                        j += 1
                    }
                }
                subjectList.remove(at: i)
                saveAssignmentList()
                saveSubjectList()
                break
            }
        }
        curFrmAssignmentList.tblSubjectList.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
        curFrmAssignmentList.refreshTableAssignmentList()
        self.dismiss(animated: true) {
        }
    }
    
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
        
        for i in 0 ... (subjectList.count - 1) {
            if (subjectList[i].name == subjectList[_EDIT_SUBJECT_ROW - 1].name) {
                var flag = false
                if (assignmentList.count > 0) {
                    for j in 0 ... (assignmentList.count - 1) {
                        if (assignmentList[j].fromFocus && assignmentList[j].subject == subjectList[i].name) {
                            flag = true
                            break
                        }
                    }
                }
                vNameBlocker.isHidden = !flag
                btnDeleteSubject.isHidden = flag
            }
        }
    }

}
