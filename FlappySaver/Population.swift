//
//  Population.swift
//  FlappySaver
//
//  Created by Gertjan on 26/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import Foundation

class Population {
    private var _genomes: [Genome] = []
    var genomes: [Genome] {
        get {
            return _genomes
        }
    }
    private var _species: [Species] = []
    var species: [Species] {
        get {
            return _species
        }
    }
    
    private let baseGenome: Genome
    let populationSize: Int
    private var _generation: Int = 0
    var generation: Int {
        return _generation
    }
    
    private let C1: Float = 1.0
    private let C2: Float = 1.0
    private let C3: Float = 0.5
    private let DT: Float = 3.0
    private let MUTATION_RATE: Float = 0.8
    private let ADD_CONNECTION_RATE: Float = 0.05
    private let ADD_NODE_RATE: Float = 0.01
    
    init(numberOfInputs: Int, numberOfOutputs: Int, populationSize: Int) {
        self.populationSize = populationSize
        baseGenome = Genome(numberOfInputs: numberOfInputs, numberOfOutputs: numberOfOutputs)
        
        for _ in 1...populationSize {
            self._genomes.append(baseGenome.copy())
        }
    }
    
    func endGeneration() {
        // Place Genomes into species
        for g in _genomes {
            var speciesFound = false
            for s in _species {
                if Genome.compatibilityDistance(genome1: g, genome2: s.mascot, c1: C1, c2: C2, c3: C3) < DT {
                    s.addMember(genome: g)
                    speciesFound = true
                    break;
                }
            }
           
            if !speciesFound {
                _species.append(Species(mascot: g))
            }
        }
        
        // Keep the best genomes and calculate staleness
        var nextGeneration: [Genome] = []
        for s in _species {
            s.keepBestGenomes()
        }
        
        // kill stale species
        _species = _species.filter({$0.staleness <= 15})
        
        // Put the best Genomes from each species into next generation
        for s in _species {
            for m in s.members {
                nextGeneration.append(m)
            }
        }
        
        #if DEBUG
        NSLog("Saved \(nextGeneration.count) Genomes!")
        #endif
        
        // Breed the rest of the genomes
        let totalSpeciesFitness = species.map({ s in s.totalAdjustedFitness }).reduce(0.0, +)
        while nextGeneration.count < self.populationSize {
            let s = self.getRandomSpeciesBiased(species: species, totalSpeciesFitness: totalSpeciesFitness)!
           
            let g1 = self.getRandomGenomeFromSpeciesBiased(species: s)!
            let g2 = self.getRandomGenomeFromSpeciesBiased(species: s)!
           
            let child: Genome
            if g1.fitness > g2.fitness {
                child = Genome.crossover(parent1: g1, parent2: g2)
            } else {
                child = Genome.crossover(parent1: g2, parent2: g1)
            }
           
            if Float.random(in: 0.0...1.0) < MUTATION_RATE {
                child.mutate()
            }
            if Float.random(in: 0.0...1.0) < ADD_CONNECTION_RATE {
                child.addConnectionMutation()
            }
            if Float.random(in: 0.0...1.0) < ADD_NODE_RATE {
                child.addNodeMutation()
            }
           
            nextGeneration.append(child)
        }
        _genomes = nextGeneration
        _generation += 1
    }
    
    private func getRandomSpeciesBiased(species: [Species], totalSpeciesFitness: Float) -> Species? {
        let r = Float.random(in: 0.0...totalSpeciesFitness)
        var countWeight: Float = 0.0
        for s in species {
            countWeight += s.totalAdjustedFitness
            if countWeight >= r {
                return s
            }
        }
        return nil // Shouldn't happen
    }

    private func getRandomGenomeFromSpeciesBiased(species: Species) -> Genome? {
        let totalSpeciesFitness = species.members.map({ g in g.fitness}).reduce(0.0, +)
        let r = Float.random(in: 0.0...totalSpeciesFitness)
        var countWeight: Float = 0.0
        for g in species.members {
            countWeight += g.fitness
            if countWeight >= r {
                return g
            }
        }
        return nil // Shouldn't happen
    }
}
