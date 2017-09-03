//
//  Classes.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import Foundation
import UIKit

class AssignmentItem: NSObject, NSCoding {
    
    
    // Variables
    
    var checked: Bool = false
    var title: String = ""
    var comments: String = ""
    var subject: String = ""
    var dueDate: Date = Date()
    var priority: Int = 0 // 0: Normal, 1: !, 2: !!
    
    // Functions
    
    override init() { }
    
    required init(coder aDecoder: NSCoder) {
        checked = aDecoder.decodeObject(forKey: "checked") as? Bool ?? false
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        comments = aDecoder.decodeObject(forKey: "comments") as? String ?? ""
        subject = aDecoder.decodeObject(forKey: "subject") as? String ?? ""
        dueDate = aDecoder.decodeObject(forKey: "dueDate") as? Date ?? Date()
        priority = aDecoder.decodeObject(forKey: "priority") as? Int ?? 0
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(checked, forKey: "checked")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(dueDate, forKey: "dueDate")
        aCoder.encode(priority, forKey: "priority")
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
