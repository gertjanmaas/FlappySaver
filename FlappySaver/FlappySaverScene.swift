//
//  FlappySaverScene.swift
//  FlappySaver
//
//  Created by Gertjan on 14/11/2019.
//  Copyright © 2019 Gertjan. All rights reserved.
//

import SpriteKit

struct GapDetails {
    var top: Float
    var bottom: Float
    var beginX: Float
    var endX: Float
}

class FlappySaverScene: SKScene, SKPhysicsContactDelegate {
    
    private var pipeGapSize: CGFloat = 20
    
    private var birds: [Bird] = []
    private var bestBird: Int = 0
    
    private var score: Double = 0.0
    private let scoreLabel = SKLabelNode(text: "Score: 0")
    private let aliveLabel = SKLabelNode(text: "Alive: 0")
    private var startTime: TimeInterval = 0.0
    
    override var acceptsFirstResponder: Bool { return false }
    
    #if DEBUG
    private var debugLines: [SKShapeNode] = []
    #endif
    
    private var population: Population?
    
    private let scale: CGFloat
    
    private let defaultsManager = DefaultsManager()
    
    init(size: CGSize, population: Population) {
        self.population = population
        self.scale = CGFloat(size.height / 1080.0)
        super.init(size: size)

        for i in 0...population.populationSize - 1 {
            self.birds.append(Bird(genome: population.genomes[i], scale: self.scale))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.population = nil
        self.scale = 1.0
        super.init(coder: aDecoder)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisonCategories.BERB_CATEGORY {
            (contact.bodyA.node as! Bird).die()
        }
        if contact.bodyB.categoryBitMask == CollisonCategories.BERB_CATEGORY {
            (contact.bodyB.node as! Bird).die()
        }

        
        for b in self.birds {
            if !b.isDead {
                return
            }
        }
        
        #if DEBUG
            removeDebugLines()
        #endif
    }
    
    private func parallexPipes() {
        self.run(SKAction.repeatForever(SKAction.sequence([
           SKAction.run { self.spawnPipes() },
           SKAction.wait(forDuration: 3.0, withRange: 1)
        ])))
    }
    
    private func createPipe(inverse: Bool, positionY: CGFloat) -> SKSpriteNode {
        let halfWidth = self.view!.frame.size.width / 2
        
        let pipe = SKSpriteNode()
        let texture = SKTexture(pathAwareName: "pipe")
        pipe.name = "pipe"
        pipe.texture = texture
        pipe.size = texture!.size()
        pipe.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        pipe.physicsBody = SKPhysicsBody(edgeLoopFrom: pipe.frame)
        pipe.physicsBody?.affectedByGravity = false
        pipe.physicsBody?.allowsRotation = false
        pipe.physicsBody?.categoryBitMask = CollisonCategories.PIPE_CATEGORY
        pipe.physicsBody?.isDynamic = false
        
        pipe.zPosition = 5;
        pipe.setScale(self.scale)
        if inverse {
            pipe.yScale *= -1
        }
        pipe.position = CGPoint(x: halfWidth + pipe.texture!.size().width, y: positionY)
        return pipe;
    }
    
    private func spawnPipes() {
        let halfWidth = self.view!.frame.size.width / 2
        let halfHeight = self.view!.frame.size.height / 2
        var maxHeight = Int(halfHeight - self.pipeGapSize)
        if maxHeight < 0 {
            maxHeight = 2
        }
        let random = Int.random(in: 1..<maxHeight)
        
        let gapCenter: CGFloat = random % 2 == 1 ? CGFloat(random) : CGFloat(random * -1)
        
        let pipe = createPipe(inverse: false, positionY: gapCenter - (self.pipeGapSize / 2))
        
        pipe.run(SKAction.sequence([
                  SKAction.move(to: CGPoint(x: (halfWidth + pipe.texture!.size().width) * -1, y: gapCenter - (self.pipeGapSize / 2)), duration: 10),
                  SKAction.removeFromParent()
              ]))
        
        let reversePipe = createPipe(inverse: true, positionY: gapCenter + (self.pipeGapSize / 2))

        reversePipe.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: (halfWidth + pipe.texture!.size().width) * -1, y: gapCenter + (self.pipeGapSize / 2)), duration: 10),
               SKAction.removeFromParent()
           ]))
        
        self.addChild(pipe)
        self.addChild(reversePipe)
    }
    
    private func spawnGround() {
        let texture = SKTexture(pathAwareName: "ground")
        let ground = SKSpriteNode()
        ground.texture = texture
        ground.size = CGSize(width: self.view!.frame.width, height: texture!.size().height)
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.categoryBitMask = CollisonCategories.GROUND_CATEGORY
        ground.physicsBody?.isDynamic = false
        ground.position = CGPoint(x: (self.view!.frame.width / 2) * -1, y: (self.view!.frame.height / 2) * -1)
        ground.zPosition = 7;
        self.addChild(ground)
    }
    
    private func spawnRoof() {
        let texture = SKTexture(pathAwareName: "ground")
        let roof = SKSpriteNode()
        roof.texture = texture
        roof.size = CGSize(width: self.view!.frame.width, height: texture!.size().height)
        roof.anchorPoint = CGPoint(x: 0, y: 0)
        roof.yScale *= -1
        
        roof.physicsBody = SKPhysicsBody(rectangleOf: roof.size)
        roof.physicsBody?.affectedByGravity = false
        roof.physicsBody?.allowsRotation = false
        roof.physicsBody?.categoryBitMask = CollisonCategories.GROUND_CATEGORY
        roof.physicsBody?.isDynamic = false
        roof.position = CGPoint(x: (self.view!.frame.width / 2) * -1, y: (self.view!.frame.height / 2))
        roof.zPosition = 7;
        self.addChild(roof)
    }
    
    private func createBackground() {
        let texture = SKTexture(pathAwareName: "background")
        let backgroundNode = SKSpriteNode(texture: texture, size: self.view!.frame.size)
        backgroundNode.texture = texture
        backgroundNode.position = CGPoint(x:0, y:0)
        backgroundNode.zPosition = 2

        self.addChild(backgroundNode)
    }
    
    #if DEBUG
    private func removeDebugLines() {
        for d in self.debugLines {
            d.removeFromParent()
        }
        self.debugLines.removeAll()
    }
    
    private func drawDebugLine(from: CGPoint, to: CGPoint) -> SKShapeNode {
        let line = SKShapeNode()
        line.name = "debug_line"
        line.zPosition = 200
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        line.path = path
        line.strokeColor = NSColor.red
        return line
    }
    
    private func drawDebugLine(bird: SKSpriteNode, to: CGPoint) {
        let line = drawDebugLine(from: bird.position, to: to)
        self.debugLines.append(line)
        self.addChild(line)
    }
    
    #endif
    
    private func getNearestGapProperties() -> GapDetails? {
        let pipes = self.children.filter { $0.name == "pipe" } as! [SKSpriteNode]
        if let nearestPipe = pipes.filter({ $0.position.x >= ($0.size.width / 2) * -1 }).min(by: { a, b in a.position.x < b.position.x }) {
            let nearestSecondPipe = pipes.filter { $0 != nearestPipe && $0.position.x == nearestPipe.position.x }[0]
            return GapDetails(
                top: Float(nearestPipe.position.y),
                bottom: Float(nearestSecondPipe.position.y),
                beginX: Float(nearestPipe.position.x) - Float(nearestPipe.size.width / 2),
                endX: Float(nearestPipe.position.x) + Float(nearestPipe.size.width / 2))
        }
       
        return nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.startTime == 0.0 {
            self.startTime = currentTime
        } else {
            self.score = currentTime - self.startTime
            if defaultsManager.showLabels {
                self.scoreLabel.text = String(format: "Score: %u", Int(self.score))
            }
        }
        #if DEBUG
            removeDebugLines()
        #endif
        
        let aliveBirds = birds.filter({ !$0.isDead })
        if aliveBirds.count == 0 {
            // All birds are dead :(
            // Evaluate fitness
            for b in self.birds {
                b.genome?.fitness = Float(b.score)
            }
            self.population!.endGeneration()
            
            self.run(SKAction.run({
                self.removeAllActions()
                let pipes = self.children.filter { $0.name == "pipe" || $0.name == "bird" }
                pipes.forEach({$0.removeAllActions()})
                self.removeAllChildren()
                self.removeFromParent()
                let newScene = FlappySaverScene(size: self.frame.size, population: self.population!)
                newScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.view?.presentScene(newScene)
            }))
        } else {
            if defaultsManager.showLabels {
                self.aliveLabel.text = String(format: "Alive: %u", Int(aliveBirds.count))
            }
            let gapDetails = getNearestGapProperties()
            // update score
            for b in birds {
                if b.isDead {
                    continue
                }
                b.score = self.score
                if gapDetails != nil {
                    // look
                    let inputs = [
                        Float((b.physicsBody?.velocity.dy)!),
                        gapDetails!.top - Float(b.position.y), // bird y to top
                        gapDetails!.bottom - Float(b.position.y), // bird y to bottom
                        gapDetails!.beginX - Float(b.position.x), // bird x to gap (begin)
                        gapDetails!.endX - Float(b.position.x) // bird x to gap (end)
                    ]
                    
                    #if DEBUG
                        drawDebugLine(bird: b, to: CGPoint(x: CGFloat(gapDetails!.beginX), y: CGFloat(gapDetails!.top)))
                        drawDebugLine(bird: b, to: CGPoint(x: CGFloat(gapDetails!.beginX), y: CGFloat(gapDetails!.bottom)))
                        drawDebugLine(bird: b, to: CGPoint(x: CGFloat(gapDetails!.endX), y: CGFloat(gapDetails!.top)))
                        drawDebugLine(bird: b, to: CGPoint(x: CGFloat(gapDetails!.endX), y: CGFloat(gapDetails!.bottom)))
                    #endif
                    
                    // think
                    let output = b.think(inputs: inputs)
                    if output[0] > 0.7 {
                        b.jump()
                    }
                    
                }
            }
            bestBird = birds.firstIndex(of: aliveBirds.max(by: {a,b in a.genome!.fitness < b.genome!.fitness })!)!
            if defaultsManager.showNetwork {
                drawBestGenomeNetwork()
            }
        }
    }
    
    private func drawBestGenomeNetwork() {
        self.removeChildren(in: self.children.filter({ $0.name == "network"}))

        let g = birds[bestBird].genome!
        let parent = SKSpriteNode()
        parent.name = "network"
        parent.zPosition = 20
        parent.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        parent.setScale(self.scale)
        
        var nodes: [Int: SKShapeNode] = [:]
        var inputs = 0
        var outputs = 0
        var hidden = 0
        for (i, n) in g.nodes {
            let nodePath = CGMutablePath()
            nodePath.addArc(center: CGPoint.zero, radius: 8, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            let node = SKShapeNode(path: nodePath)
            node.zPosition = 2
            node.lineWidth = 1
            node.strokeColor = .white
            switch n.type {
            case NodeGeneType.Input:
                node.fillColor = NSColor.init(red: 30.0/255.0, green: 144.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                node.position = CGPoint(x: 0, y: inputs * 30)
                inputs += 1
            case NodeGeneType.Output:
                if birds[bestBird].jumped {
                    node.fillColor = NSColor.init(red: 50.0/255.0, green: 205.0/255.0, blue: 50.0/255.0, alpha: 1.0)
                } else {
                    node.fillColor = NSColor.init(red: 220.0/255.0, green: 20.0/255.0, blue: 60.0/255.0, alpha: 1.0)
                }
                node.position = CGPoint(x: 150, y: outputs * 30)
                outputs += 1
            case NodeGeneType.Hidden:
                node.fillColor = NSColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
                node.position = CGPoint(x: 75, y: hidden * 30)
                hidden += 1
            }
            nodes[i] = node
            parent.addChild(node)
        }
        
        for (_, c) in g.connections {
            let line = SKShapeNode()
            line.zPosition = 1
            let path = CGMutablePath()
            path.move(to: nodes[c.inNode]!.position)
            path.addLine(to: nodes[c.outNode]!.position)
            line.path = path
            line.strokeColor = .white
            parent.addChild(line)
        }
        parent.position = CGPoint(
            x: self.size.width / 2 - (180 * self.scale),
            y: ((self.size.height / 2) - 40) * -1
        )
        self.addChild(parent)
    }
    
    override func didMove(to view: SKView) {
        self.resignFirstResponder()
        self.isUserInteractionEnabled = false
        
        self.removeAllActions()
        self.removeAllChildren()
        
        self.backgroundColor = NSColor(red: 67/255.0, green: 152/255.0, blue: 199/255.0, alpha: 1.0)
        
        createBackground()
        
        self.pipeGapSize = SKTexture(pathAwareName: "flappy")!.size().height * 5.0 * self.scale
        physicsWorld.contactDelegate = self
        
        if defaultsManager.showLabels {
            let generationLabel = SKLabelNode(text: "Generation: \(self.population!.generation)")
            generationLabel.zPosition = 20
            generationLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
            generationLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            generationLabel.fontColor = SKColor.black
            generationLabel.fontName = "Helvetica-Bold"
            generationLabel.position = CGPoint(x: ((self.frame.size.width / 2) - 20) * -1, y: (self.frame.size.height / 2) - 40);
            generationLabel.setScale(self.scale)
            self.addChild(generationLabel)
            
            self.scoreLabel.zPosition = 20
            self.scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
            self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            self.scoreLabel.fontColor = SKColor.black
            self.scoreLabel.fontName = "Helvetica-Bold"
            self.scoreLabel.position = CGPoint(x: ((self.frame.size.width / 2) - 20) * -1, y: (self.frame.size.height / 2) - (40 + (40 * self.scale)));
            self.scoreLabel.setScale(self.scale)
            self.addChild(self.scoreLabel)
            
            
            self.aliveLabel.zPosition = 20
            self.aliveLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
            self.aliveLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            self.aliveLabel.fontColor = SKColor.black
            self.aliveLabel.fontName = "Helvetica-Bold"
            self.aliveLabel.position = CGPoint(x: ((self.frame.size.width / 2) - 20) * -1, y: (self.frame.size.height / 2) - (40 + (80 * self.scale)));
            self.aliveLabel.setScale(self.scale)
            self.addChild(self.aliveLabel)
        }
        
        spawnGround()
        spawnRoof()
        parallexPipes()
        
        for b in self.birds {
            self.addChild(b)
        }
    }
}
