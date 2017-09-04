//
//  frmAssignmentList.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import M13Checkbox

var tableAssignmentList: [AssignmentItem] = [] // The assignment list that is displayed

class frmAssignmentList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Form Outlets
    
    @IBOutlet weak var vLeft: UIView!
    @IBOutlet weak var vRight: UIView!
    @IBOutlet weak var vRightCenter: UIView!
    @IBOutlet weak var tblAssignmentList: UITableView!
    
    // Variables
    
    
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAssignmentList.delegate = self
        tblAssignmentList.dataSource = self
    
        
        curFrmAssignmentList = self
        
        let nsAssignments = UserDefaults.standard.object(forKey: "assignmentList")
        if (nsAssignments != nil) {
            assignmentList = NSKeyedUnarchiver.unarchiveObject(with: nsAssignments as! Data) as! [AssignmentItem]
        }
        
        let nsSubjects = UserDefaults.standard.object(forKey: "subjectList")
        if (nsSubjects != nil) {
            subjectList = NSKeyedUnarchiver.unarchiveObject(with: nsSubjects as! Data) as! [SubjectItem]
        }
        
        let nsCurAssignmentID = UserDefaults.standard.object(forKey: "curAssignmentID")
        if (nsCurAssignmentID != nil) {
            curAssignmentID = NSKeyedUnarchiver.unarchiveObject(with: nsCurAssignmentID as! Data) as! Int
        }
        
        if (subjectList.count == 0) {
            let defaultSubject = SubjectItem()
            defaultSubject.name = __DEFAULT_SUBJECT_NAME
            defaultSubject.color = UIColor.darkGray
            subjectList.append(defaultSubject)
            saveSubjectList()
        }
        
        refreshTableAssignmentList()
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == tblAssignmentList) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableAssignmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: frmAsignmentList_tblAssignmentListCell = tableView.dequeueReusableCell(withIdentifier: "tblAssignmentListCell_Identifier", for: indexPath) as! frmAsignmentList_tblAssignmentListCell
        cell.rowNumber = indexPath.row
        cell.loadCell()
        return cell
    }
    
    // MARK: - Table View Data
    
    func refreshTableAssignmentList () {
        if (assignmentList.count == 0) {
            tableAssignmentList = []
            return
        }
        if (assignmentList.count == 1) {
            tableAssignmentList = assignmentList
        } else {
            var i: Int = 0, j: Int = 0
            tableAssignmentList = assignmentList
            for i in 0 ... (tableAssignmentList.count - 2) {
                for j in (i + 1) ... (tableAssignmentList.count - 1) {
                    if (tableAssignmentList[i].dueDate > tableAssignmentList[j].dueDate) {
                        swap(&tableAssignmentList[i], &tableAssignmentList[j])
                    } else if (tableAssignmentList[i].dueDate == tableAssignmentList[j].dueDate) {
                        if (tableAssignmentList[i].priority < tableAssignmentList[j].priority) {
                            swap(&tableAssignmentList[i], &tableAssignmentList[j])
                        } else if (tableAssignmentList[i].priority == tableAssignmentList[j].priority) {
                            if (tableAssignmentList[i].subject.compare(tableAssignmentList[j].subject) == ComparisonResult.orderedAscending) {
                                swap(&tableAssignmentList[i], &tableAssignmentList[j])
                            }
                        }
                    }
                }
            }
        }
        tblAssignmentList.reloadData()
    }
    
    
    // MARK: - Test Only
    
    @IBAction func clearAll(_ sender: Any) {
        assignmentList = []
        subjectList = []
        let defaultSubject = SubjectItem()
        defaultSubject.name = __DEFAULT_SUBJECT_NAME
        defaultSubject.color = UIColor.darkGray
        subjectList.append(defaultSubject)
        saveAssignmentList()
        saveSubjectList()
        refreshTableAssignmentList()
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

