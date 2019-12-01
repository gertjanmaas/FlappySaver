//
//  DefaultsManager.swift
//  FlappySaver
//
//  Created by Gertjan on 01/12/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import ScreenSaver

class DefaultsManager {
    
    var defaults: UserDefaults
    
    init() {
        let identifier = "codes.maas.gertjan.FlappySaver"
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)!
        defaults.register(defaults: [
            "NumberOfBirds": 30,
            "ShowNetwork": true,
            "ShowLabels": true,
        ])
        
        NSLog("Flappy: Settings \(numberOfBirds), \(showNetwork), \(showLabels)")
    }
    
    var numberOfBirds: Int {
        set(newNumber) {
            defaults.set(newNumber, forKey: "NumberOfBirds")
            defaults.synchronize()
        }
        get {
            return defaults.integer(forKey: "NumberOfBirds")
        }
    }
    
    var showNetwork: Bool {
        set(newValue) {
            defaults.set(newValue, forKey: "ShowNetwork")
            defaults.synchronize()
        }
        get {
            return defaults.bool(forKey: "ShowNetwork")
        }
    }
    
    var showLabels: Bool {
        set(newValue) {
            defaults.set(newValue, forKey: "ShowLabels")
            defaults.synchronize()
        }
        get {
            return defaults.bool(forKey: "ShowLabels")
        }
    }
}
