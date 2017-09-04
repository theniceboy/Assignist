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
    @IBOutlet weak var lbSubject: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var vChecked: UIView!
    @IBOutlet weak var lbSectionHeader: UILabel!
    @IBOutlet weak var lbDueTime: UILabel!
    
    @IBOutlet weak var _layout_vMasterTopMargin: NSLayoutConstraint!
    
    // MARK: - UI
    
    var subjectUIColor: UIColor = UIColor.gray
    var cChecked: M13Checkbox = M13Checkbox()
    var rowNumber: Int = 0
    
    // MARK: - Functions
    
    func onSameDay (date1: Date, date2: Date) -> Bool {
        return (date1.year == date2.year && date1.month == date2.month && date1.day == date2.day)
    }
    
    
    // MARK: - Load
    
    func showSectionHeader () {
        vMaster.heightAnchor.constraint(equalToConstant: 130).isActive = true
        _layout_vMasterTopMargin.constant = 36
        self.layoutIfNeeded()
        lbSectionHeader.isHidden = false
        var assignmentCounter: Int = 1
        if (rowNumber < tableAssignmentList.count - 1) {
            while (onSameDay(date1: tableAssignmentList[rowNumber + assignmentCounter - 1].dueDate, date2: tableAssignmentList[rowNumber + assignmentCounter].dueDate)) {
                assignmentCounter += 1
                if (rowNumber + assignmentCounter >= tableAssignmentList.count) {
                    break
                }
            }
        }
        lbSectionHeader.text = "\(assignmentCounter) Assignment" + (assignmentCounter > 1 ? "s" : "") + " Due " + (abs(daysDifference(date1: Date.today(), date2: tableAssignmentList[rowNumber].dueDate)) > 1 ? "On " : "") + dateFormat_Word(date: tableAssignmentList[rowNumber].dueDate)
    }
    
    func hideSectionHeader () {
        vMaster.heightAnchor.constraint(equalToConstant: 100).isActive = true
        _layout_vMasterTopMargin.constant = 2
        self.layoutIfNeeded()
        lbSectionHeader.isHidden = true
    }
    
    func loadCell() {
        
        // Set Cell UI
        
        if (rowNumber == 0) {
            showSectionHeader()
        } else {
            if (onSameDay(date1: tableAssignmentList[rowNumber - 1].dueDate, date2: tableAssignmentList[rowNumber].dueDate)) {
                hideSectionHeader()
            } else {
                showSectionHeader()
            }
        }
        
        
        vMaster.layer.shadowColor = UIColor.black.cgColor
        vMaster.layer.shadowOffset = CGSize.zero
        vMaster.layer.shadowOpacity = 0.1
        vMaster.layer.shadowRadius = 5
        vMaster.layer.cornerRadius = 10
        
        vSubject.layer.cornerRadius = 10
        
        lbTitle.tag = rowNumber
        lbTitle.text = tableAssignmentList[rowNumber].title
        lbSubject.text = tableAssignmentList[rowNumber].subject
        lbDueTime.text = "Due At " + (tableAssignmentList[rowNumber].dueDate.minute < 10 ? " " : "") + "\(tableAssignmentList[rowNumber].dueDate.hour):" + (tableAssignmentList[rowNumber].dueDate.minute < 10 ? "0" : "") + "\(tableAssignmentList[rowNumber].dueDate.minute)"
        
        cChecked = M13Checkbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        cChecked.stateChangeAnimation = .expand(.fill)
        cChecked.boxType = .square
        cChecked.cornerRadius = 4
        vChecked.addSubview(cChecked)
        print(getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id))
        if (assignmentList[getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id)].checked) {
            cChecked.toggleCheckState(true)
        }
        
        subjectUIColor = subjectColor(string: tableAssignmentList[rowNumber].subject)
        vSubject.backgroundColor = subjectUIColor
        cChecked.tintColor = subjectUIColor
        
        lbSubject.textColor = subjectUIColor
        
    }
    
    func toggleCheckBox () {
        cChecked.toggleCheckState(true)
        if (cChecked.checkState == M13Checkbox.CheckState.checked) {
            assignmentList[getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id)].checked = true
        } else {
            assignmentList[getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id)].checked = false
        }
        print("HAHAHAHAHAHAHA")
        print(assignmentList[getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id)].id)
        print(assignmentList[getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id)].title)
        print(assignmentList[getRowNum_AssignmentList(id: tableAssignmentList[rowNumber].id)].checked)
        saveAssignmentList()
    }
    
    @IBAction func btnCheck_Tapped(_ sender: Any) {
        toggleCheckBox()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

