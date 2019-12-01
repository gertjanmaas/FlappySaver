//
//  ConnectionGene.swift
//  FlappySaver
//
//  Created by Gertjan on 19/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

class ConnectionGene {
    let inNode: Int
    let outNode: Int
    let innovationNumber: Int
    
    var weight: Float
    var expressed: Bool
    
    init(inNode: Int, outNode: Int, weight: Float, expressed: Bool, innovationNumber: Int){
        self.inNode = inNode
        self.outNode = outNode
        self.weight = weight
        self.expressed = expressed
        self.innovationNumber = innovationNumber
    }
    
    func copy() -> ConnectionGene {
        return ConnectionGene(inNode: self.inNode, outNode: self.outNode, weight: self.weight, expressed: self.expressed, innovationNumber: self.innovationNumber)
    }
    
    func mutate() {
        let r = Float.random(in: 0.0...1.0)
        if r < 0.1 {
            // new random value
            self.weight = Float.random(in: -1.0...1.0)
        } else {
            self.weight += (Float.random(in: -1.0...1.0) / 50)
        }
        if self.weight > 1.0 {
            self.weight = 1.0
        }
        if self.weight < -1.0 {
            self.weight = -1.0
        }
    }
}
