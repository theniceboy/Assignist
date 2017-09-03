//
//  frmAsignmentList_tblAssignmentListCell.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import M13Checkbox

class frmAsignmentList_tblAssignmentListCell: UITableViewCell {
    
    // MAKR: - Outlets
    
    @IBOutlet weak var vMaster: UIView!
    @IBOutlet weak var vSubject: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var vChecked: UIView!
    
    // MARK: - UI
    
    var cChecked: M13Checkbox = M13Checkbox()
    var rowNum: Int = 0
    
    // MARK: - Load
    
    func loadCell(rowNumber: Int) {
        
        rowNum = rowNumber
        
        // Set Cell UI
        
        vMaster.heightAnchor.constraint(equalToConstant: 100).isActive = true
        vMaster.layer.shadowColor = UIColor.black.cgColor
        vMaster.layer.shadowOffset = CGSize.zero
        vMaster.layer.shadowOpacity = 0.1
        vMaster.layer.shadowRadius = 5
        vMaster.layer.cornerRadius = 10
        
        vSubject.layer.cornerRadius = 10
        
        lbTitle.tag = rowNumber
        lbTitle.text = assignmentList[rowNumber].title
        
        cChecked = M13Checkbox(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        cChecked.stateChangeAnimation = .stroke
        vChecked.addSubview(cChecked)
    }
    
    @IBAction func btnCheck_Tapped(_ sender: Any) {
        cChecked.toggleCheckState(true)
        if (cChecked.checkState == M13Checkbox.CheckState.checked) {
            assignmentList[rowNum].checked = true
        } else {
            assignmentList[rowNum].checked = false
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

