//
//  frmAssignmentList_tblSubject_Cell.swift
//  Assignments
//
//  Created by David Chen on 9/9/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

class frmAssignmentList_tblSubject_Cell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var vSubjectColor: UIView!
    @IBOutlet weak var lbSubjectName: UILabel!
    @IBOutlet weak var btnEditSubject: UIButton!
    
    // MARK: - Variables
    
    var rowNumber: Int = 0
    var curSubject: SubjectItem = SubjectItem()
    
    // MARK: - Initialization
    
    func loadCell () {
        self.heightAnchor.constraint(equalToConstant: 70)
        
        vContent.layer.cornerRadius = 6
        
        curSubject = tableSubjectList[rowNumber]
        
        vSubjectColor.layer.shadowRadius = 3
        vSubjectColor.layer.shadowColor = UIColor.gray.cgColor
        vSubjectColor.layer.shadowOpacity = 0.3
        vSubjectColor.layer.shadowOffset = CGSize.zero
        vSubjectColor.layer.cornerRadius = 6
        
        if (rowNumber == 0) {
            vSubjectColor.backgroundColor = UIColor.white
            btnEditSubject.isHidden = true
        } else if (rowNumber == 1) {
            vSubjectColor.backgroundColor = curSubject.color
            btnEditSubject.isHidden = true
        } else {
            vSubjectColor.backgroundColor = curSubject.color
            btnEditSubject.isHidden = false
        }
        lbSubjectName.text = curSubject.name
        
        if (tableSubjectList_selectedRow == rowNumber) {
            vContent.backgroundColor = themeColor.withAlphaComponent(0.2)
        } else {
            vContent.backgroundColor = UIColor.clear
        }
    }
    
    @IBAction func btnEdit_Tapped(_ sender: Any) {
        _EDIT_SUBJECT_ROW = rowNumber
    }
}
