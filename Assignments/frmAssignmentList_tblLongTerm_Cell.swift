//
//  frmAssignmentList_tblLongTerm_Cell.swift
//  Assignments
//
//  Created by David Chen on 9/28/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

class frmAssignmentList_tblLongTerm_Cell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var vMaster: UIView!
    @IBOutlet weak var vSubject: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubject: UILabel!
    @IBOutlet weak var btnTop: ZFRippleButton!
    
    // MARK: - Variables
    
    var rowNumber: Int = 0
    var tmpAssignment: AssignmentItem = AssignmentItem()
    var subjectUIColor: UIColor = UIColor.gray
    
    // MARK: - Functions
    
    func loadCell () {
        tmpAssignment = tableLongTerm[rowNumber]
        subjectUIColor = subjectColor(string: tmpAssignment.subject)
        
        vMaster.layer.shadowColor = UIColor.black.cgColor
        vMaster.layer.shadowOffset = CGSize.zero
        vMaster.layer.shadowOpacity = 0.1
        vMaster.layer.shadowRadius = 3
        vMaster.layer.cornerRadius = 6
        
        vSubject.layer.cornerRadius = 6
        vSubject.layer.backgroundColor = subjectUIColor.cgColor
        
        
        lbTitle.text = tmpAssignment.title
        lbSubject.text = tmpAssignment.subject
        
        lbSubject.textColor = subjectUIColor
        //lbSubject.
        
        btnTop.rippleColor = subjectUIColor.withAlphaComponent(0.3)
        btnTop.rippleBackgroundColor = UIColor.white.withAlphaComponent(0)
    }
    
    // MARK: - Actions
    
    @IBAction func btnTop_Tapped(_ sender: Any) {
        if (tableAssignmentList.count > 0) {
            for i in 0 ... (tableAssignmentList.count - 1) {
                if (tableAssignmentList[i].id == tmpAssignment.id) {
                    
                    curFrmAssignmentList.tblAssignmentList.scrollToRow(at: IndexPath(row: i, section: 0), at: UITableViewScrollPosition.middle, animated: false)
                    //print(curFrmAssignmentList.tblAssignmentList.cellForRow(at: IndexPath(row: i, section: 0)))
                    if let row = curFrmAssignmentList.tblAssignmentList.cellForRow(at: IndexPath(row: i, section: 0)) {
                        (row as! frmAsignmentList_tblAssignmentListCell).highLight()
                    }
                    break
                }
            }
        }
    }
    
}
