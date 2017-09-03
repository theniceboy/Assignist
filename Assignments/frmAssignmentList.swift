//
//  frmAssignmentList.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import M13Checkbox

class frmAssignmentList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Form Outlets
    
    @IBOutlet weak var vLeft: UIView!
    @IBOutlet weak var vRight: UIView!
    @IBOutlet weak var vRightCenter: UIView!
    @IBOutlet weak var tblAssignmentList: UITableView!
    
    
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
            subjectList = NSKeyedUnarchiver.unarchiveObject(with: nsAssignments as! Data) as! [SubjectItem]
        }
        
        if (subjectList.count == 0) {
            let defaultSubject = SubjectItem()
            defaultSubject.name = __DEFAULT_SUBJECT_NAME
            defaultSubject.color = UIColor.darkGray
        }
        
        tblAssignmentList.reloadData()
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == tblAssignmentList) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: frmAsignmentList_tblAssignmentListCell = tableView.dequeueReusableCell(withIdentifier: "tblAssignmentListCell_Identifier", for: indexPath) as! frmAsignmentList_tblAssignmentListCell
        cell.loadCell(rowNumber: indexPath.row)
        return cell
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

