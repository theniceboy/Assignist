//
//  Gib.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Global Variables

var assignmentList: [AssignmentItem] = []
var subjectList: [SubjectItem] = []

var myCalender: Calendar = Calendar.current

let __DEFAULT_SUBJECT_NAME = "Uncategorized"

var loggedInFocus: Bool = false

// MARK: - Live Viewcontrollers

var curFrmAssignmentList: frmAssignmentList = frmAssignmentList()
var curFrmAssignmentList_NewAssignment: frmAssignmentList_NewAssignment = frmAssignmentList_NewAssignment()
var curFrmAssignmentList_NewAssignment_NewSubject:frmAssignmentList_NewAssignment_NewSubject = frmAssignmentList_NewAssignment_NewSubject()
var curFrmAssignmentList_LoginFocusPopup: frmAssignmentList_LoginFocusPopup = frmAssignmentList_LoginFocusPopup()
var curFrmSettings: frmSettings = frmSettings()

// MARK: - Colors

var themeColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0) // Theme blue color
var redColor = UIColor(red: 208.0 / 255.0, green: 2.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0) // red color
var scrollGray = UIColor(red: 92.0 / 255.0, green: 94.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)

// MARK: - Hash for Date

let h_iday: [String: Int] = ["Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4, "Friday": 5, "Saturday": 6, "Sunday": 7]
let h_day: [Int: String] = [1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday", 5: "Friday", 6: "Saturday", 7: "Sunday"]
let h_uday: [Int: String] = [-1: "Yesterday", 0: "Today", 1: "Tomorrow"]
let h_week: [Int: String] = [0: "Last ", 1: "", 2: "Next "]

// MARK: - Global Functions

func onSameDay (date1: Date, date2: Date) -> Bool {
    return (date1.year == date2.year && date1.month == date2.month && date1.day == date2.day)
}

func displayTime (date: Date) -> String {
    if (date.hour > 12 || (date.hour == 12 && date.minute > 0)) {
        return "\((date.hour == 12 ? 12 : date.hour - 12)):" + (date.minute < 10 ? "0" : "") + "\(date.minute) PM"
    }
    return "\(date.hour):" + (date.minute < 10 ? "0" : "") + "\(date.minute) AM"
}

func weekOfYear (date: Date) -> Int {
    return myCalender.component(.weekOfYear, from: date)
}

func dayOfWeek (date: Date) -> Int {
    return date.weekday == 1 ? 7 : date.weekday - 1
}

func daysDifference (date1: Date, date2: Date) -> Int {
    // Replace the hour (time) of both dates with 00:00
    let date1 = myCalender.startOfDay(for: date1)
    let date2 = myCalender.startOfDay(for: date2)
    
    return myCalender.dateComponents([.day], from: date1, to: date2).day!
}

func dateFormat_Word (date: Date) -> String {
    let uday: Int = daysDifference(date1: localDate(), date2: date)
    let nday = dayOfWeek(date: date)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = " (MM/dd)"
    //let advanced_str: String = (abs(uday) > 1 ? (uday > 1 ? "（\(uday) days later）" : "（\(abs(uday)) days ago）") : "")
    let advanced_str: String = " (\(date.month)/\(date.day))"
    if (abs(uday) > 14) {
        return "\(date.month)/\(date.day)/\(date.year)" + advanced_str
    }
    if (abs(uday) < 2) {
        return h_uday[uday]! + advanced_str
    } else if (weekOfYear(date: date) == weekOfYear(date: localDate())) {
        return h_day[nday]! + advanced_str
    } else if (abs(weekOfYear(date: date) - weekOfYear(date: localDate())) < 2) {
        var str: String = ""
        if (abs(uday) >= 7 || (uday > 0 && nday < dayOfWeek(date: localDate())) || (uday < 0 && nday > dayOfWeek(date: localDate()))) {
            str = ((uday > 0) ? h_week[2] : h_week[0])!
        }
        str += h_day[nday]!
        return str + advanced_str
    }
    return "\(date.month)/\(date.day)/\(date.year)" + advanced_str
}

func localDate()-> Date {
    return Date()
    var interval = TimeZone.current.secondsFromGMT()
    if (!TimeZone.current.isDaylightSavingTime(for: Date())) {
        interval -= 3600
    }
    return Date().addingTimeInterval(TimeInterval(interval))
    //return Date().description(with: Locale.current)
}

func correctedDate1 (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int = 0) -> Date {
    let date = Date(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    var interval = TimeZone.current.secondsFromGMT()
    if (!TimeZone.current.isDaylightSavingTime(for: date)) {
        interval -= 3600
    }
    return date.addingTimeInterval(TimeInterval(interval))
}

func printDate (date: Date) {
    print("_______PRINTDATE________ \(date.year).\(date.month).\(date.day)  \(date.hour):\(date.minute)")
}
