//
//  Species.swift
//  FlappySaver
//
//  Created by Gertjan on 24/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

class Species {
    private var _mascot: Genome;
    var mascot: Genome {
        get {
            return _mascot;
        }
    }
    private var _members: [Genome] = [];
    var members: [Genome] {
        get {
            return _members
        }
    }
    var totalAdjustedFitness: Float = 0.0
    var bestFitness: Float = 0.0
    var staleness: Int = 0
    
    init(mascot: Genome) {
        self._mascot = mascot;
        addMember(genome: mascot)
    }
    
    func addMember(genome: Genome) {
        _members.append(genome)
        totalAdjustedFitness = _members.map({ m in m.fitness }).reduce(0.0, +) / Float(_members.count)
    }
    
    func keepBestGenomes() {
        let bestGenome = members.max { a,b in a.fitness < b.fitness }!
        if bestGenome.fitness > bestFitness {
           bestFitness = bestGenome.fitness
           staleness = 0
        } else {
            staleness += 1
        }
        _members.removeAll()
        self._mascot = bestGenome
        addMember(genome: bestGenome)
    }
}
