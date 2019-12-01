//
//  SKSceneExtensions.swift
//  FlappySaver
//
//  Created by Gertjan on 14/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import SpriteKit

extension SKScene {

    static func fromBundle(fileName: String, bundle: Bundle?) -> SKScene? {
        guard let bundle = bundle else { return nil }
        guard let path = bundle.path(forResource: fileName, ofType: "sks") else { return nil }
        if let data = FileManager.default.contents(atPath: path) {
            do {
                let scene: SKScene = try NSKeyedUnarchiver.unarchivedObject(ofClass: SKScene.self, from: data)!
                return scene
            } catch {
                return nil
            }
        }
        return nil
    }
}
