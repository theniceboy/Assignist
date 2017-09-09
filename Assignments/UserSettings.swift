//
//  UserSettings.swift
//  Assignments
//
//  Created by David Chen on 9/5/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import Foundation

class UserSettings: NSObject, NSCoding {
    
    // Variables
    
    var defaultPushNotificationTime_hour: Int = 20
    var defaultPushNotificationTime_minute: Int = 00
    
    var focusUsername: String = ""
    var focusPassword: String = ""
    
    // Functions
    
    override init() { }
    
    required init(coder aDecoder: NSCoder) {
        defaultPushNotificationTime_hour = aDecoder.decodeInteger(forKey: "defaultPushNotificationTime_hour")
        defaultPushNotificationTime_minute = aDecoder.decodeInteger(forKey: "defaultPushNotificationTime_minute")
        focusUsername = (aDecoder.decodeObject(forKey: "focusUsername") as? String)!
        focusPassword = (aDecoder.decodeObject(forKey: "focusPassword") as? String)!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(defaultPushNotificationTime_hour, forKey: "defaultPushNotificationTime_hour")
        aCoder.encode(defaultPushNotificationTime_minute, forKey: "defaultPushNotificationTime_minute")
        aCoder.encode(focusUsername, forKey: "focusUsername")
        aCoder.encode(focusPassword, forKey: "focusPassword")
    }
}

var userSettings: UserSettings = UserSettings()

func saveUserSettings () {
    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: userSettings), forKey: "userSettings")
}

func loadUserSettings () {
    let _userSettings = UserDefaults.standard.object(forKey: "userSettings")
    if (_userSettings != nil) {
        userSettings = NSKeyedUnarchiver.unarchiveObject(with: _userSettings as! Data) as! UserSettings
    } else {
        userSettings = UserSettings()
        
    }
}
