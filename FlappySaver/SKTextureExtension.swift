//
//  SKTextureExtension.swift
//  FlappySaver
//
//  Created by Gertjan on 16/10/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import SpriteKit

extension SKTexture {
    public convenience init?(pathAwareName name: String) {
        let bundle = Bundle.pathAwareBundle()
        
        if let textureUrl = bundle.path(forResource: name, ofType: "png") {
            let image = NSImage(byReferencingFile: textureUrl)
            self.init(image: image!)
        } else {
            self.init(imageNamed: name)
        }
    }
}
