//
//  ConfigureSheetController.swift
//  FlappySaver
//
//  Created by Gertjan on 01/12/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import Cocoa

class ConfigureSheetController : NSObject {
    
    var defaultsManager = DefaultsManager()

    @IBOutlet var window: NSWindow?
    @IBOutlet weak var showNetwork: NSButton?
    @IBOutlet weak var showLabels: NSButton?
    @IBOutlet weak var numberOfBirds: NSSliderCell?
    @IBOutlet weak var numberOfBirdsLabel: NSTextField?
    
    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)
        showNetwork?.state = defaultsManager.showNetwork ? .on : .off
        showLabels?.state = defaultsManager.showLabels ? .on : .off
        numberOfBirds?.intValue = Int32(defaultsManager.numberOfBirds)
        numberOfBirdsLabel!.stringValue = "\(self.numberOfBirds!.intValue)"
    }

    @IBAction func updateShowNetwork(_ sender: Any) {
        defaultsManager.showNetwork = self.showNetwork?.state == .on ? true : false
    }
    
    @IBAction func updateShowLabels(_ sender: Any) {
        defaultsManager.showLabels = self.showLabels?.state == .on ? true : false
    }
    
    @IBAction func updateNumberOfBirds(_ sender: Any) {
        numberOfBirdsLabel!.stringValue = "\(self.numberOfBirds!.intValue)"
       defaultsManager.numberOfBirds = Int(self.numberOfBirds!.intValue)
    }
    
    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        window?.endSheet(window!)
    }
}
