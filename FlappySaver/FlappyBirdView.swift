//
//  FlappyBirdView.swift
//  FlappySaver
//
//  Created by Gertjan on 14/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import SpriteKit

class FlappyBirdView: SKView {
    
    override var acceptsFirstResponder: Bool { return false }

    override var frame: NSRect {
        didSet
        {
            self.scene?.size = frame.size
        }
    }
    
    private var population: Population
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        let scene = FlappySaverScene(size: self.frame.size, population: self.population)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.presentScene(scene)
    }
    
    private static func initializePopulation() -> Population {
        return Population(numberOfInputs: 4, numberOfOutputs: 1, populationSize: DefaultsManager().numberOfBirds)
    }
    
    override init(frame: NSRect) {
        self.population = FlappyBirdView.initializePopulation()
        super.init(frame:frame)
    }
    
    required init?(coder: NSCoder) {
        self.population = FlappyBirdView.initializePopulation()
        super.init(coder: coder)
    }
}
