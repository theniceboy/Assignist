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
var tableAssignmentList_checked: [AssignmentItem] = []
var tableAssignmentListDivider: Int = 0 // The index of the first item that shoud be in the completed section

class frmAssignmentList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Form Outlets
    
    @IBOutlet weak var vLeft: UIView!
    @IBOutlet weak var vRight: UIView!
    @IBOutlet weak var vRightCenter: UIView!
    @IBOutlet weak var tblAssignmentList: UITableView!
    @IBOutlet weak var btnShowCompleted: ZFRippleButton!
    
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
    
    // MARK: - Actions
    
    @IBAction func btnAdd_Tapped(_ sender: Any) {
        _EDIT_MODE_ = false
    }
    
    var showingChecked: Bool = false
    @IBAction func btnShowCompleted_Tapped(_ sender: Any) {
        showingChecked = !showingChecked
        btnShowCompleted.setTitle((showingChecked ? "Hide Completed" : "Show Completed"), for: .normal)
        self.refreshTableAssignmentList()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return ""
        } else {
            return "Completed"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: frmAsignmentList_tblAssignmentListCell = tableView.dequeueReusableCell(withIdentifier: "tblAssignmentListCell_Identifier", for: indexPath) as! frmAsignmentList_tblAssignmentListCell
        cell.rowNumber = indexPath.row
        cell.loadCell()
        return cell
    }
    
    // MARK: - Table View Data
    
    func swaptable (a: Int, b: Int) {
        var c = tableAssignmentList[a]
        tableAssignmentList[a] = tableAssignmentList[b]
        tableAssignmentList[b] = c
    }
    
    func swaptable_checked (a: Int, b: Int) {
        var c = tableAssignmentList_checked[a]
        tableAssignmentList_checked[a] = tableAssignmentList_checked[b]
        tableAssignmentList_checked[b] = c
    }
    
    func formatTableData () {
        var i: Int = 0, j: Int = 0, k: Int = 0
        tableAssignmentList = []
        tableAssignmentList_checked = []
        if (assignmentList.count == 0) {
            return
        }
        if (assignmentList.count == 1) {
            if (assignmentList[0].checked) {
                tableAssignmentList_checked.append(assignmentList[0])
            } else {
                tableAssignmentList.append(assignmentList[0])
            }
        } else {
            for i in 0 ... (assignmentList.count - 1) {
                if (assignmentList[i].checked) {
                    tableAssignmentList_checked.append(assignmentList[i])
                } else {
                    tableAssignmentList.append(assignmentList[i])
                }
            }
            tableAssignmentListDivider = tableAssignmentList.count
            if (tableAssignmentList.count > 1) {
                for i in 0 ... (tableAssignmentList.count - 2) {
                    for j in (i + 1) ... (tableAssignmentList.count - 1) {
                        if (tableAssignmentList[i].dueDate.timeIntervalSince1970 > tableAssignmentList[j].dueDate.timeIntervalSince1970) {
                            swaptable(a: i, b: j)
                        } else if (tableAssignmentList[i].dueDate == tableAssignmentList[j].dueDate) {
                            if (tableAssignmentList[i].priority < tableAssignmentList[j].priority) {
                                swaptable(a: i, b: j)
                            } else if (tableAssignmentList[i].priority == tableAssignmentList[j].priority) {
                                if (tableAssignmentList[i].subject.compare(tableAssignmentList[j].subject) == ComparisonResult.orderedDescending) {
                                    swaptable(a: i, b: j)
                                }
                            }
                        }
                    }
                }
            }
            if (tableAssignmentList_checked.count > 1) {
                for i in 0 ... (tableAssignmentList_checked.count - 2) {
                    for j in (i + 1) ... (tableAssignmentList_checked.count - 1) {
                        if (tableAssignmentList_checked[i].dueDate.timeIntervalSince1970 > tableAssignmentList_checked[j].dueDate.timeIntervalSince1970) {
                            swaptable_checked(a: i, b: j)
                        }
                    }
                }
            }
            
            if (showingChecked) {
                tableAssignmentList.append(contentsOf: tableAssignmentList_checked)
            }
        }
    }
    
    func refreshShowCompletedButton () {
        if (tableAssignmentList_checked.count == 0) {
            showingChecked = false
            btnShowCompleted.setTitle("Show Completed", for: .normal)
            btnShowCompleted.isEnabled = false
            btnShowCompleted.setTitleColor(scrollGray, for: .normal)
        } else {
            btnShowCompleted.isEnabled = true
            btnShowCompleted.setTitleColor(themeColor, for: .normal)
        }
    }
    
    func refreshTableAssignmentList (formatTable: Bool = true) {
        
        if (formatTable) {
            formatTableData()
        }
        
        printTableAssignments()
        
        refreshShowCompletedButton()
        
        tblAssignmentList.reloadData()
        /*
        var allRows: [IndexPath] = []
        if (tableAssignmentList.count > 0) {
            for i in 0 ... (tableAssignmentList.count - 1) {
                allRows.append(IndexPath(row: i, section: 0))
            }
        }
        tblAssignmentList.reloadRows(at: allRows, with: UITableViewRowAnimation.none)
         */
        //tblAssignmentList.reloadSections([1], with: .none)
    }
    
    // MARK: - Table View Action
    
    func editAssignment (id: Int) {
        _EDIT_ID_ = id
        _EDIT_MODE_ = true
        self.performSegue(withIdentifier: "segueShowFrmNewAssignment", sender: self)
    }
    
    // MARK: - Test Only
    
    @IBAction func clearAll(_ sender: Any) {
        printAssignments()
        /*
        assignmentList = []
        subjectList = []
        let defaultSubject = SubjectItem()
        defaultSubject.name = __DEFAULT_SUBJECT_NAME
        defaultSubject.color = UIColor.darkGray
        subjectList.append(defaultSubject)
        saveAssignmentList()
        saveSubjectList()
        refreshTableAssignmentList()
 */
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

