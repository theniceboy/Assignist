//
//  Classes.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import Foundation
import UIKit

var curAssignmentID: Int = 1

func saveCurAssignmentID () {
    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: curAssignmentID), forKey: "curAssignmentID")
}

class AssignmentItem: NSObject, NSCoding {
    
    
    // Variables
    
    var id: Int = 0
    var checked: Bool = false
    var title: String = ""
    var comments: String = ""
    var subject: String = ""
    var dueDate: Date = Date()
    var priority: Int = 0 // 0: Normal, 1: !, 2: !!
    
    // Functions
    
    override init() { }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeInteger(forKey: "id")
        checked = aDecoder.decodeBool(forKey: "isChecked")
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        comments = aDecoder.decodeObject(forKey: "comments") as? String ?? ""
        subject = aDecoder.decodeObject(forKey: "subject") as? String ?? ""
        dueDate = aDecoder.decodeObject(forKey: "dueDate") as? Date ?? Date()
        priority = aDecoder.decodeInteger(forKey: "priority")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(checked, forKey: "isChecked")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(dueDate, forKey: "dueDate")
        aCoder.encode(priority, forKey: "priority")
    }
}

func getRowNum_AssignmentList (id: Int) -> Int {
    for var i in 0 ... assignmentList.count - 1 {
        if (assignmentList[i].id == id) {
            return i
        }
    }
    print ("NOOOOOOOOOO!!!!!!!!!")
    return -1
}

func printAssignments () {
    for var item in assignmentList {
        print("\(item.id) \(item.checked) " + item.title + " " +  dateFormat_Word(date: item.dueDate) + "\(item.dueDate.hour):\(item.dueDate.minute)")
    }
}

func printTableAssignments () {
    print("--------")
    for var item in tableAssignmentList {
        print("\(item.id) \(item.checked) " + item.title + " " +  dateFormat_Word(date: item.dueDate) + "\(item.dueDate.hour):\(item.dueDate.minute)")
    }
}

func saveAssignmentList () {
    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: assignmentList), forKey: "assignmentList")
}


class SubjectItem: NSObject, NSCoding {
    
    override init() { }
    
    // Variables
    
    var name: String = ""
    var color: UIColor = UIColor.lightGray
    
    // Functions
    
    required init(coder aDecoder: NSCoder) {
        name = (aDecoder.decodeObject(forKey: "name") as? String)!
        color = (aDecoder.decodeObject(forKey: "color") as? UIColor)!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(color, forKey: "color")
    }
}

func saveSubjectList () {
    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: subjectList), forKey: "subjectList")
}

func subjectColor (string: String) -> UIColor {
    for item: SubjectItem in subjectList {
        if (item.name == string) {
            return item.color
        }
    }
    return UIColor.darkGray
}
