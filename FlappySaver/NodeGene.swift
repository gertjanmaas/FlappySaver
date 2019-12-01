//
//  NodeGene.swift
//  FlappySaver
//
//  Created by Gertjan on 19/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

enum NodeGeneType {
    case Input, Hidden, Output
}

class NodeGene {
    let type: NodeGeneType
    let id: Int
    var value: Float = 0.0
    
    init(id: Int, type: NodeGeneType) {
        self.id = id
        self.type = type
    }
    
    func copy() -> NodeGene {
        return NodeGene(id: self.id, type: self.type)
    }
}
