//: Playground - noun: a place where people can play

import Foundation
import UIKit
import PlaygroundSupport


class focusAssignmentItem {
    var title: String = ""
    var duedateStr: String = ""
    var subject: String = ""
}

var focusassignmentList: [AssignmentItem] = []

PlaygroundPage.current.needsIndefiniteExecution = true

var request = URLRequest(url: URL(string: "https://focus.mvcs.org/focus")!)

request.httpMethod = "POST"
request.httpBody = ("username=weichen&password=Tdou2121").data(using: .utf8)

let session = URLSession.shared
let task = session.dataTask(with: request) { (_data, _response, _error) in
    if (_error != nil) {
        print ("error: \(String(describing: _error))")
    } else if (_data != nil) {
        let httpstr: String = String(data: _data!, encoding: String.Encoding.ascii)!
        var beginIndex = httpstr.startIndex
        while (beginIndex < httpstr.endIndex) {
            let range = beginIndex ..< httpstr.index(beginIndex, offsetBy: 21)
            print(httpstr[range])
            if (httpstr[range] == "Upcoming Assignments") {
                break
            }
            beginIndex = httpstr.index(beginIndex, offsetBy: 1)
        }
        print(beginIndex)
    }
}

task.resume()
// Upcoming Assignments
