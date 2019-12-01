//
//  Genome.swift
//  FlappySaver
//
//  Created by Gertjan on 19/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//
import Foundation

class Genome {
    var connections: [Int: ConnectionGene] = [:]
    var nodes: [Int: NodeGene] = [:]
    var inputs: [Int: NodeGene] = [:]
    var outputs: [Int: NodeGene] = [:]
    var fitness: Float = 0.0
    
    init(numberOfInputs: Int, numberOfOutputs: Int) {
        if numberOfInputs > 0 {
            for i in 0...(numberOfInputs - 1) {
                nodes[i] = NodeGene(id: i, type: NodeGeneType.Input)
                inputs[i] = nodes[i]
            }
        }
        
        if numberOfOutputs > 0 {
            for i in 0...(numberOfOutputs - 1) {
                nodes[numberOfInputs + i] = NodeGene(id: numberOfInputs + i, type: NodeGeneType.Output)
                outputs[i] = nodes[numberOfInputs + i]
            }
        }
        
        if numberOfInputs > 0 && numberOfOutputs > 0 {
            for i in 0...(numberOfInputs - 1) {
                for o in 0...(numberOfOutputs - 1) {
                    let innovationNumber = InnovationGenerator.innovationNumber
                    connections[innovationNumber] = ConnectionGene(inNode: i, outNode: numberOfInputs + o, weight: 1.0, expressed: true, innovationNumber: innovationNumber )
                }
            }
        }
    }
    
    func copy() -> Genome {
        let g = Genome(numberOfInputs: 0, numberOfOutputs: 0)
        for (i,n) in self.nodes {
            g.nodes[i] = n.copy()
        }
        for (i,c) in self.connections {
            g.connections[i] = c.copy()
        }
        
        for (i,_) in self.inputs {
            g.inputs[i] = g.nodes[i]
        }
        for (i,_) in self.outputs {
            g.outputs[i] = g.nodes[g.inputs.count + i]
        }
        return g
    }
    
    func addConnectionMutation() {
        let node1 = nodes.randomElement()!.value
        let node2 = nodes.randomElement()!.value
        
        if (node1.type == NodeGeneType.Input && node2.type == NodeGeneType.Input) ||
            (node1.type == NodeGeneType.Output && node2.type == NodeGeneType.Output) {
            return
        }
        
        let reversed = (node1.type == NodeGeneType.Hidden && node2.type == NodeGeneType.Input) ||
            (node1.type == NodeGeneType.Output && node2.type == NodeGeneType.Hidden) ||
            (node1.type == NodeGeneType.Output && node2.type == NodeGeneType.Input)
            
        let existingConnection = connections.filter {
            ($0.value.inNode == node1.id && $0.value.outNode == node2.id) ||
            ($0.value.inNode == node2.id && $0.value.outNode == node1.id)
        }
        
        if existingConnection.count > 0 {
            return
        }
        
        let newConnection = ConnectionGene(inNode: reversed ? node2.id : node1.id, outNode: reversed ? node1.id : node2.id, weight: Float.random(in: -1.0...1.0), expressed: true, innovationNumber: InnovationGenerator.innovationNumber)
        self.connections[newConnection.innovationNumber] = newConnection
    }
    
    func addNodeMutation() {
        let connection = connections.randomElement()!.value
        
        let inNode = connection.inNode
        let outNode = connection.outNode
        
        connection.expressed = false
        
        let newNode = NodeGene(id: self.nodes.count, type: NodeGeneType.Hidden)
        let inToNew = ConnectionGene(inNode: inNode, outNode: newNode.id, weight: 1.0, expressed: true, innovationNumber: InnovationGenerator.innovationNumber)
        let newToOut = ConnectionGene(inNode: newNode.id, outNode: outNode, weight: connection.weight, expressed: true, innovationNumber: InnovationGenerator.innovationNumber)
        self.nodes[nodes.count] = newNode
        self.connections[inToNew.innovationNumber] = inToNew
        self.connections[newToOut.innovationNumber] = newToOut
    }
    
    func mutate() {
        let r = Float.random(in: 0.0...1.0)
        if r < 0.8 {
            for (_, n) in self.connections {
                n.mutate()
            }
        }
    }
    
    static func crossover(parent1: Genome, parent2: Genome) -> Genome {
        // Assuming parent1 is the fitter parent
        let child = parent1.copy()
        child.connections.removeAll()
        
        for (i,n) in parent1.connections {
            if (parent2.connections[i] != nil) {
                // matching gene
                if Bool.random() {
                    child.connections[i] = parent1.connections[i]!.copy()
                } else {
                    child.connections[i] = parent2.connections[i]!.copy()
                }
            } else {
                // disjoint/excess gene
                child.connections[i] = n.copy()
            }
        }
        
        return child
    }
    
    static func compatibilityDistance(genome1: Genome, genome2: Genome, c1: Float, c2: Float, c3: Float) -> Float {
        let highestInnovationNumber1 = genome1.connections.keys.max()!
        let highestInnovationNumber2 = genome2.connections.keys.max()!
        let highestInnovationNumber = max(highestInnovationNumber1, highestInnovationNumber2)
        let highestNodeCount1 = genome1.nodes.keys.max()!
        let highestNodeCount2 = genome2.nodes.keys.max()!
        let highestNodeCount = max(highestNodeCount1, highestNodeCount2)
        
        var weightDifferenceMatchingGenes: Float = 0.0
        var matchingGenes: Float = 0.0
        var disjointGenes: Float = 0.0
        var excessGenes: Float = 0.0
        
        for i in 0...highestNodeCount - 1 {
            let node1 = genome1.nodes[i]
            let node2 = genome2.nodes[i]
            
            if node1 != nil && node2 != nil {
                matchingGenes += 1
            } else {
                if node1 == nil && node2 != nil {
                    if i < highestNodeCount1 {
                        disjointGenes += 1;
                    } else {
                        excessGenes += 1;
                    }
                }
                if node2 == nil && node1 != nil {
                    if i < highestNodeCount2 {
                        disjointGenes += 1;
                    } else {
                        excessGenes += 1;
                    }
                }
            }
        }
        
        for i in 0...highestInnovationNumber - 1 {
            let con1 = genome1.connections[i]
            let con2 = genome2.connections[i]
           
            if con1 != nil && con2 != nil {
                matchingGenes += 1
                weightDifferenceMatchingGenes += abs(con1!.weight - con2!.weight)
            } else {
                if con1 == nil && con2 != nil {
                    if i < highestInnovationNumber1 {
                        disjointGenes += 1;
                    } else {
                        excessGenes += 1;
                    }
                }
                if con2 == nil && con1 != nil {
                    if i < highestInnovationNumber2 {
                        disjointGenes += 1;
                    } else {
                        excessGenes += 1;
                    }
                }
            }
        }

        return (excessGenes * c1) + (disjointGenes * c2) + (weightDifferenceMatchingGenes * c3)
    }
    
    private func stepFunction(x: Float) -> Float {
        return (x < 0.0) ? 0.0 : 1.0
    }
    
    private func sigmoid(x: Float) -> Float {
        return Float(1.0 / (1.0 + pow(M_E, Double(-4.9 * x))));
    }
    
    func engage(inputs: [Float]) -> [Float] {
        
        // reset node values
        nodes.forEach({ (_,n) in n.value = 0.0 })

        for (i,n) in self.inputs {
            n.value = inputs[i]
        }
      
        for (_,n) in self.nodes {
            if n.type == NodeGeneType.Output {
                continue
            }
            var outputValue = n.value
            if n.type != NodeGeneType.Input {
                // Use activation function
                outputValue = sigmoid(x: n.value)
            }
            let connections = self.connections.filter { $0.value.inNode == n.id }
            for (_, c) in connections {
                self.nodes[c.outNode]!.value += (outputValue * c.weight)
            }
            
        }
        
        return self.outputs.map({ i,o in o.value })
    }
}
