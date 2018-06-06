//
//  GameScene.swift
//  Fall Everywhere
//
//  Created by Geoffrey Grimaud on 5/17/18.
//  Copyright © 2018 GEI. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    private var debug : Bool = true
    private let screenW : CGFloat = UIScreen.main.bounds.size.width
    private let screenH : CGFloat = UIScreen.main.bounds.size.height
    private let radius : CGFloat = CGFloat(sqrtf(Float(pow(UIScreen.main.bounds.size.width, 2) + pow(UIScreen.main.bounds.size.height, 2))))
//    private let angle : CGFloat =
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var player : SKSpriteNode?
    private var spinnyNode : SKShapeNode?
    private var target : CGPoint?
    

    @objc func x() {
        var position = CGPoint(x: 200, y: 0)
        var circle = SKShapeNode(circleOfRadius: self.radius)
        var maxHoles = self.maxBreaks()
        circle.position = position
        circle.strokeColor = SKColor.white
        circle.lineWidth = 10.0
        circle.fillColor = SKColor.clear
        var path = circle.path!
//        path.li
        circle.physicsBody = SKPhysicsBody(edgeLoopFrom: circle.path!)
//        self.addChild(circle)
        var offset = atan(min(screenW, screenH)/max(screenH, screenW))
        var arc = UIBezierPath(arcCenter: position, radius: self.radius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi/2+offset, clockwise: true)
        var square = SKShapeNode(path: arc.cgPath)
        self.addChild(square)
        
        if debug {
            var point = SKShapeNode(circleOfRadius: CGFloat(5))
        point.position = position
        point.fillColor = SKColor.red
        self.addChild(point)
        }
        if let player = self.player {
        }
    }
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//debug") as? SKLabelNode
        self.player = self.childNode(withName: "//player") as? SKSpriteNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
        if let player = self.player {
            player.alpha = 0.0
            player.run(SKAction.fadeIn(withDuration: 2.0))
            self.target = player.position
        }
        
        // Create shape node to use during mouse interaction
        if debug {
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        }
    }
    
    private func maxBreaks() -> CGFloat {
        return floor(min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)/max(self.player!.size.width, self.player!.size.height))
    }
    
    override func didMove(to view: SKView) {
        //enable physics
        self.physicsWorld.contactDelegate = self
        
        //add doubletap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(x))
        doubleTap.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTap)
        
        //add walls around screen
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.collisionBitMask = (self.player?.physicsBody?.collisionBitMask)!
        self.player?.physicsBody?.collisionBitMask = (self.physicsBody?.collisionBitMask)!
    }
    
    func touchDown(atPoint pos : CGPoint) {
        self.target = pos
        if debug {
//            print(self.maxBreaks())
//            print(UIScreen.main.bounds.size.width)
//            print(self.player!.size.height)
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        self.target = pos
        if let player = self.player {
            player.run(SKAction.move(to: self.target!, duration: 0.1))
        }
        if debug {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
            let a = String(format: "%.2f", pos.x)
            let b = String(format: "%.2f", pos.y)
            let c = String(format: "%.2f", (player?.position.x)!)
            let d = String(format: "%.2f", (player?.position.y)!)
            self.label?.text = a + ", " + b + "\r\n" + c + ", " + d
        }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if debug {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
        if let player = self.player {
//            player.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // detect for collision
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
