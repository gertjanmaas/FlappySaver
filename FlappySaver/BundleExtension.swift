//
//  BundleExtension.swift
//  FlappySaver
//
//  Created by Gertjan on 16/10/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//
import Cocoa

extension Bundle {
    static func pathAwareBundle() -> Bundle {
        return Bundle(for: object_getClass(FlappySaverScene.self)!)
    }
}
