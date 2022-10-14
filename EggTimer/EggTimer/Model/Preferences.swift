//
//  Preferences.swift
//  EggTimer
//
//  Created by wiwi on 2022/10/14.
//

import Foundation

struct Preferences {
    var selectedTime: TimeInterval {
        get {
            let storedTime = UserDefaults.standard.double(forKey: "selectedTime")
            if storedTime > 0 {
                return storedTime
            }
            return 360
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedTime")
        }
    }
}
