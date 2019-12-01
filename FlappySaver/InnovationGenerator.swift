//
//  InnovationGenerator.swift
//  FlappySaver
//
//  Created by Gertjan on 19/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

class InnovationGenerator {
    static private var _innovationNumber: Int = 0
    static var innovationNumber: Int {
        get {
            self._innovationNumber += 1
            return self._innovationNumber
        }
    }
    
}
