//
//  frmAssignmentList_NewAssignment_NewSubject.swift
//  Assignments
//
//  Created by David Chen on 9/3/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

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
            return
        }
        for item in subjectList {
            if (name == item.name) {
                tfName.errorMessage = "The subject \"" + name + "\" already exists"
                return
            }
        }
        newSubject(name: name)
        curFrmAssignmentList.refreshTableSubject()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addedSubject"), object: nil)
        self.dismiss(animated: true, completion: {
        })
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

func cgfloatABS (value: CGFloat) -> CGFloat {
    return (value < 0 ? -value : value)
}

func newSubjectColor () -> UIColor {
    var colorOK: Bool = false, newColor: UIColor = UIColor.white
    var firstR: CGFloat = 0, secondR: CGFloat = 0
    var firstG: CGFloat = 0, secondG: CGFloat = 0
    var firstB: CGFloat = 0, secondB: CGFloat = 0
    var firstAlpha: CGFloat = 0, secondAlpha: CGFloat = 0
    for _ in 0 ... 100000 {
    //while (!colorOK) {
        newColor = randomColor(hue: Hue.random, luminosity: Luminosity.light)
        colorOK = true
        for item in subjectList {
            newColor.getRed(&firstR, green: &firstG, blue: &firstB, alpha: &firstAlpha)
            if (firstR + firstG + firstB < 1) {
                colorOK = false
                break
            }
            item.color.getRed(&secondR, green: &secondG, blue: &secondB, alpha: &secondAlpha)
            if (cgfloatABS(value: (firstR - secondR)) +
                cgfloatABS(value: (firstG - secondG)) +
                cgfloatABS(value: (firstB - secondB)) < 0.4) {
                colorOK = false
                break
            }
        }
        
        if (colorOK) {
            break
        }
 
    }
    return newColor
}

func newSubject (name: String, fromFocus: Bool = false) {
    let newSubjectItem: SubjectItem = SubjectItem()
    newSubjectItem.name = name
    newSubjectItem.color = newSubjectColor()
    newSubjectItem.fromFocus = fromFocus
    subjectList.append(newSubjectItem)
    saveSubjectList()
}
