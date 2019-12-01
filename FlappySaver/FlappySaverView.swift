//
//  FlappySaverView.swift
//  FlappySaver
//
//  Created by Gertjan on 14/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import ScreenSaver
import SpriteKit

class FlappySaverView: ScreenSaverView {
    var skView: SKView!
    
    var defaultsManager: DefaultsManager = DefaultsManager()
    lazy var sheetController: ConfigureSheetController = ConfigureSheetController()
    
    override public var hasConfigureSheet: Bool {
        return true
    }
    
    override public var configureSheet: NSWindow? {
        return sheetController.window
    }

    
    override init?(frame: NSRect, isPreview: Bool) {
        let realIsPreview: Bool
        if frame.width < 400 && frame.height < 300 {
            super.init(frame: frame, isPreview: true)
            realIsPreview = true
        } else {
            super.init(frame: frame, isPreview: false)
            realIsPreview = false
        }

        let isMainScreen = NSScreen.main!.frame == frame
        if realIsPreview || isMainScreen {
            self.skView = FlappyBirdView(frame: self.bounds)
            #if DEBUG
            self.skView.showsFPS = true
            self.skView.showsPhysics = false
            self.skView.showsNodeCount = true
            #endif
            
            self.addSubview(skView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
