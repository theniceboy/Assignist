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
    var fromFocus: Bool = false
    var newFromFocus: Bool = false
    var notificationOn: Bool = false
    var checkedDate: Date = Date()
    
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
        fromFocus = aDecoder.decodeBool(forKey: "fromFocus")
        newFromFocus = aDecoder.decodeBool(forKey: "newFromFocus")
        notificationOn = aDecoder.decodeBool(forKey: "notificationOn")
        checkedDate = aDecoder.decodeObject(forKey: "checkedDate") as? Date ?? Date()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(checked, forKey: "isChecked")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(dueDate, forKey: "dueDate")
        aCoder.encode(priority, forKey: "priority")
        aCoder.encode(fromFocus, forKey: "fromFocus")
        aCoder.encode(newFromFocus, forKey: "newFromFocus")
        aCoder.encode(notificationOn, forKey: "notificationOn")
        aCoder.encode(checkedDate, forKey: "checkedDate")
    }
}

func getRowNum_AssignmentList (id: Int) -> Int {
    if (assignmentList.count > 0) {
        for i in 0 ... (assignmentList.count - 1) {
            if (assignmentList[i].id == id) {
                return i
            }
        }
    }
    print ("NOOOOOOOOOO!!!!!!!!!")
    return -1
}

func printAssignments () {
    for item in assignmentList {
        print("\(item.id) \(item.checked) " + item.title + " " + item.subject + " " +  dateFormat_Word(date: item.dueDate) + "\(item.dueDate.hour):\(item.dueDate.minute)")
    }
}

func printSubjects () {
    for item in subjectList {
        print(item.name + "\(item.color)")
    }
}

func printTableAssignments () {
    print("--------")
    for item in tableAssignmentList {
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
    var fromFocus: Bool = false
    
    // Functions
    
    required init(coder aDecoder: NSCoder) {
        name = (aDecoder.decodeObject(forKey: "name") as? String)!
        color = (aDecoder.decodeObject(forKey: "color") as? UIColor)!
        fromFocus = aDecoder.decodeBool(forKey: "fromFocus")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(color, forKey: "color")
        aCoder.encode(fromFocus, forKey: "fromFocus")
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
