//
//  ViewController.swift
//  FlappyTester
//
//  Created by Gertjan on 17/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    private var population: Population = Population(numberOfInputs: 4, numberOfOutputs: 1, populationSize: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            let scene = FlappySaverScene(size: view.frame.size, population: self.population)
            
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
            view.presentScene(scene)
        }
    }
}

