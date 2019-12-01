//
//  Bird.swift
//  FlappySaver
//
//  Created by Gertjan on 17/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import SpriteKit

class Bird: SKSpriteNode {
    
    var isDead = false;
    var score: Double = 0.0
    
    var genome: Genome?
    
    private var _jumped: Bool = false
    var jumped: Bool {
        get {
            return _jumped
        }
    }
    
    init(genome: Genome, scale: CGFloat = 1.0) {
        self.genome = genome
        let texture = SKTexture(pathAwareName: "flappy")
        super.init(texture: texture, color: NSColor.clear, size: texture!.size() )
        
        self.name = "bird"
        self.size = self.texture!.size()
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.texture!.size())
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = CollisonCategories.BERB_CATEGORY
        self.physicsBody?.collisionBitMask = CollisonCategories.PIPE_CATEGORY | CollisonCategories.GROUND_CATEGORY
        self.physicsBody?.contactTestBitMask = CollisonCategories.PIPE_CATEGORY | CollisonCategories.GROUND_CATEGORY
        self.zPosition = 10;
        self.zRotation = .pi / 6
        self.setScale(scale)
    }
    
    func jump() {
        _jumped = true
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        self.run(SKAction.sequence([
            SKAction.rotate(toAngle: .pi / 6, duration: 0.2),
            SKAction.rotate(toAngle: .pi * -1, duration: 2.0),
        ]))
    }
    
    func die() {
        _jumped = false
        self.isDead = true
        self.removeAllActions()
        self.removeFromParent()
    }
    
    func revive() {
        _jumped = false
        self.isDead = false
    }
    
    func think(inputs: [Float]) -> [Float] {
        _jumped = false
        return genome!.engage(inputs: inputs)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.genome = nil
        super.init(coder: aDecoder)
    }
}
