//
//  Classes.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import Foundation

class AssignmentItem {
    
    // Variables
    
    var title: String = ""
    var comments: String = ""
    var subject: String = ""
    var noDueDate: Bool = false
    var dueDate: Date = Date()
    var dueDateDefault: Int = 0 // 0: Morning, 1: Midnight
    var priority: Int = 0 // 0: Normal, 1: !, 2: !!
    
    // Functions
    
    init () {
        
    }
}
