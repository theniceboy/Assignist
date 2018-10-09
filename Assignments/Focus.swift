//
//  Focus.swift
//  Assignments
//
//  Created by David Chen on 9/7/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class focusAssignmentItem {
    var title: String = ""
    var duedatestr: String = ""
    var period: Int = 0

    var subject: String = ""
    var duedate: Date = Date()
}

func subchar (charlist: [Character], a: Int, b: Int) -> String {
    var str = ""
    for i in a ... b {
        str.append(charlist[i])
    }
    return str
}

func parseFocusHTML (html: String, subjectstr: String) {
    //print(html)
    /*
    var subEndIndex = html.startIndex
    var isSuccess: Bool = false
    while (indexNow < html.endIndex) {
        subEndIndex = html.index(indexNow, offsetBy: 20) ?? html.endIndex
        substr = String(html[indexNow ..< subEndIndex])
        if (substr == "Upcoming Assignments") {
            isSuccess = true
            indexNow = html.index(indexNow, offsetBy: 22)
            break
        }
        indexNow = html.index(after: indexNow)
    }
     print(html)
     print("______SubjectStr")
     print(subjectstr)
 */
    if (html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" && userSettings.focusUsername != "" && userSettings.focusPassword != "") {
        
        // Set all newFromFocus to false
        for item in assignmentList {
            item.newFromFocus = false
        }
        
        var indexNow = html.index(after: html.startIndex)
        var strlist: [String] = []
        indexNow = html.startIndex
        
        // Get lines
        while (true) {
            if (html[indexNow] == ">") {
                indexNow = html.index(after: indexNow)
                while (indexNow < html.endIndex && html[indexNow] == " ") {
                    indexNow = html.index(after: indexNow)
                }
                var newstr = ""
                while (indexNow < html.endIndex && html[indexNow] != "<") {
                    newstr.append(html[indexNow])
                    indexNow = html.index(after: indexNow)
                }
                if (newstr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "") {
                    strlist.append(newstr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                }
            }
            if (indexNow == html.endIndex) {
                break
            }
            indexNow = html.index(after: indexNow)
        }
        
        if (strlist.count < 3) {
            return
        }
        
        var assignmentState: Int = 0 // 0: Title, 1: Due Date, 2: Subject
        var focusAssignmentList: [focusAssignmentItem] = []
        var curPeriod: Int = 0
        assignmentState = 2
        
        var i: Int = 0
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM d yyyy h:ss aa"
        //dateFormatter.dateStyle = .medium
        //dateFormatter.timeStyle = .short
        var tmpdatestr = "", tmpnextdatestr = ""
        //var tmpdatestrIndex = " ".startIndex
        //print(strlist)
        while (i < strlist.count) {
            tmpdatestr = strlist[i]
            if tmpdatestr.count > 3 {
                tmpdatestr.remove(at: tmpdatestr.startIndex)
                tmpdatestr.remove(at: tmpdatestr.startIndex)
                tmpdatestr.remove(at: tmpdatestr.startIndex)
                tmpdatestr.remove(at: tmpdatestr.startIndex)
            }
            if (strlist[i].starts(with: "Due:") && dateFormatter.date(from: tmpdatestr) != nil) {
                assignmentState = 1
            } else if (i < strlist.count - 1) {
                tmpnextdatestr = strlist[i + 1]
                if tmpnextdatestr.count > 3 {
                    tmpnextdatestr.removeFirst()
                    tmpnextdatestr.removeFirst()
                    tmpnextdatestr.removeFirst()
                    tmpnextdatestr.removeFirst()
                }
                if (strlist[i + 1].starts(with: "Due:") && dateFormatter.date(from: tmpnextdatestr) != nil) {
                    assignmentState = 0
                } else {
                    assignmentState = 2
                }
            } else {
                assignmentState = 1
            }
            if (assignmentState == 0) {
                let newItem = focusAssignmentItem()
                newItem.title = strlist[i]
                newItem.period = curPeriod
                focusAssignmentList.append(newItem)
                assignmentState = 1
            } else if (assignmentState == 1) {
                focusAssignmentList[focusAssignmentList.count - 1].duedatestr = tmpdatestr
                //print(dateFormatter.string(from: Date()))
                //let date = dateFormatter.date(from: tmpdatestr)!
                //print(date)
                focusAssignmentList[focusAssignmentList.count - 1].duedate = dateFormatter.date(from: tmpdatestr)!
                assignmentState = 0
            } else {
                let number = strlist[i][strlist[i].index(strlist[i].startIndex, offsetBy: 7)]
                curPeriod = Int("\(number)")!
                assignmentState = 0
            }
            i = i + 1
        }
        
        // Find Period Names
        indexNow = subjectstr.startIndex
        strlist = []
        var tmpsubjectList: [Int: String] = [:]
        while (true) {
            if (subjectstr[indexNow] == ">") {
                indexNow = subjectstr.index(after: indexNow)
                while (indexNow < subjectstr.endIndex && subjectstr[indexNow] == " ") {
                    indexNow = subjectstr.index(after: indexNow)
                    //print("_mid" + String(subjectstr[indexNow]))
                }
                var newstr = ""
                while (indexNow < subjectstr.endIndex && subjectstr[indexNow] != "<") {
                    newstr.append(subjectstr[indexNow])
                    indexNow = subjectstr.index(after: indexNow)
                }
                if (newstr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" && newstr.contains("Period") && !newstr.starts(with: "Period")) {
                    //print("\"" + newstr + "\"")
                    strlist.append(newstr)
                }
            }
            if (indexNow == subjectstr.endIndex) {
                break
            }
            indexNow = subjectstr.index(after: indexNow)
        }
        
        var tmpSubject = "", tmpPeriod = "", syncedAssignmentCount = 0
        if (strlist.count > 0) {
            for i in 0 ... (strlist.count - 1) {
                tmpSubject = ""
                tmpPeriod = ""
                
                var chars = Array(strlist[i])
                var j = 0, charl = chars.count
                while (j < charl - 7) {
                    if (subchar(charlist: chars, a: j, b: j + 8) == " - Period") {
                        break
                    }
                    tmpSubject.append(chars[j])
                    j += 1
                }
                j += 10
                while (j < chars.count - 1 && chars[j] != " ") {
                    tmpPeriod.append(chars[j])
                    j += 1
                }
                
                /*
                indexNow = strlist[i].startIndex
                while (strlist[i][indexNow] != "-" && indexNow < strlist[i].endIndex) {
                    tmpSubject.append(strlist[i][indexNow])
                    indexNow = strlist[i].index(after: indexNow)
                }
                indexNow = strlist[i].index(after: indexNow)
                indexNow = strlist[i].index(after: indexNow)
                while (strlist[i][indexNow] != " " && indexNow < strlist[i].endIndex) {
                    tmpPeriod.append(strlist[i][indexNow])
                    indexNow = strlist[i].index(after: indexNow)
                }
                indexNow = strlist[i].index(after: indexNow)
                tmpPeriod = ""
                while (strlist[i][indexNow] != " " && indexNow < strlist[i].endIndex) {
                    tmpPeriod.append(strlist[i][indexNow])
                    indexNow = strlist[i].index(after: indexNow)
                }
 */
                tmpsubjectList[Int(tmpPeriod)!] = tmpSubject.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: "&amp;", with: "&")
                //print(tmpSubject + "  " + tmpPeriod)
            }
            
            /*
 [0]    String    "ASB Leadership - Period 1 - BCD - 070 - Jennifer  Keathley"
             [1]    String    "Chemistry Hon - Period 2 - BCD - 001 - Marsha  Tarr"    [2]    String    "Spanish I - Period 3 - BCD - 255 - Michael  Lanham"    [3]    String    "AP Govt &amp; Politics US - Period 4 - ACD - 149 - Alexis  Salerno"    [4]    String    "Precal/Trig Hon - Period 5 - ACD - 235 - Kent  Tarr"    [5]    String    "English II Hon - Period 6 - ACD - 001 - Amber  West"    [6]    String    "Biblical Narrative-Discipleship - Period 7 - ACD - 003 - Jeremy  Scott"
 */
            
            
            for item in focusAssignmentList {
                item.title = item.title.replacingOccurrences(of: "&amp;", with: "&")
                item.subject = item.subject.replacingOccurrences(of: "&amp;", with: "&")
            }
            
            var assignmentExists: Bool = false, subjectExists: Bool = false
            for i in 0 ... (focusAssignmentList.count - 1) {
                focusAssignmentList[i].subject = tmpsubjectList[focusAssignmentList[i].period]!
                assignmentExists = false
                if (assignmentList.count > 0) {
                    for aindex in 0 ... (assignmentList.count - 1) {
                        // Synced assignment but the date might be different
                        if (focusAssignmentList[i].title == assignmentList[aindex].title && focusAssignmentList[i].subject == assignmentList[aindex].subject) {
                            if (assignmentList[aindex].dueDate != focusAssignmentList[i].duedate) {
                                //assignmentList[aindex].newFromFocus = true
                                assignmentList[aindex].dueDate = focusAssignmentList[i].duedate
                                //syncedAssignmentCount += 1
                            }
                            assignmentExists = true
                            break
                        }
                    }
                }
                
                if (!assignmentExists) {
                    subjectExists = false
                    for item in subjectList {
                        if (focusAssignmentList[i].subject == item.name) {
                            subjectExists = true
                            break
                        }
                    }
                    if (!subjectExists) {
                        newSubject(name: focusAssignmentList[i].subject, fromFocus: true)
                    }
                    
                    let assignmentItem = AssignmentItem()
                    assignmentItem.id = curAssignmentID
                    curAssignmentID += 1
                    saveCurAssignmentID()
                    assignmentItem.title = focusAssignmentList[i].title
                    assignmentItem.comments = "" //"Synced from focus"
                    assignmentItem.subject = focusAssignmentList[i].subject
                    assignmentItem.dueDate = focusAssignmentList[i].duedate
                    assignmentItem.fromFocus = true
                    assignmentItem.newFromFocus = true
                    
                    assignmentList.append(assignmentItem)
                    
                    var notifyDateTime = Date(), tmpDueDate = focusAssignmentList[i].duedate
                    registerNotification()
                    if (abs(daysDifference(date1: localDate(), date2: tmpDueDate)) > 0) {
                        notifyDateTime = tmpDueDate.addingTimeInterval(-86400)
                        notifyDateTime = Date(year: notifyDateTime.year, month: notifyDateTime.month, day: notifyDateTime.day, hour: userSettings.defaultPushNotificationTime_hour, minute: userSettings.defaultPushNotificationTime_minute, second: 0)
                    } else {
                        notifyDateTime = Date(year: tmpDueDate.year, month: tmpDueDate.month, day: tmpDueDate.day, hour: userSettings.defaultPushNotificationTime_hour, minute: userSettings.defaultPushNotificationTime_minute, second: 0)
                        
                        if (!(localDate() < notifyDateTime && notifyDateTime < tmpDueDate)) {
                            notifyDateTime = Date(year: tmpDueDate.year, month: tmpDueDate.month, day: tmpDueDate.day, hour: (localDate().hour + tmpDueDate.hour) / 2, minute: 30, second: 0)
                        }
                    }
                    
                    let notification = UILocalNotification()
                    notification.fireDate = notifyDateTime
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.userInfo = ["id": assignmentItem.id]
                    notification.alertBody = "[" + assignmentItem.subject + "] " + assignmentItem.title
                    UIApplication.shared.scheduleLocalNotification(notification)
                    
                    syncedAssignmentCount += 1
                }
            }
        }
        
        loggedInFocus = true
        
        if (loginFromSettigns) {
            SwiftSpinner.sharedInstance.innerColor = UIColor.green.withAlphaComponent(0.5)
            SwiftSpinner.sharedInstance.outerColor = UIColor.white
            SwiftSpinner.show(duration: 1.5, title: "Connected To Focus", animated: false)
            curFrmSettings.showLogoutButton()
        } else {
            curFrmAssignmentList.activityStop()
            if (syncedAssignmentCount == 0) {
                Drop.down("Your assignment list is up to date", state: .success, duration: 1.5, action: {
                })
            } else {
                Drop.down("Synced \(syncedAssignmentCount) New Assignments From Focus", state: .success, duration: 1.5, action: {
                })
            }
        }
        /*
        for item in checkedIDBeforeFocusSync {
            if (assignmentList.count > 0) {
                for i in 0 ... (assignmentList.count - 1) {
                    if (assignmentList[i].id == item) {
                        assignmentList[i].checked = false
                        break
                    }
                }
            }
        }
        for item in checkedIDBeforeFocusSync {
            if (assignmentList.count > 0) {
                for i in 0 ... (assignmentList.count - 1) {
                    if (assignmentList[i].id == item) {
                        assignmentList[i].checked = true
                        break
                    }
                }
            }
        }
        checkedIDBeforeFocusSync = []
 */
        curFrmAssignmentList.refreshTableAssignmentList(formatTable: true)
        saveAssignmentList()
        saveSubjectList()
        saveUserSettings()
        
    }
}
