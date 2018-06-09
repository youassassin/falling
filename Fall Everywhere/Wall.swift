//
//  Wall.swift
//  Fall Everywhere
//
//  Created by Geoffrey Grimaud on 6/8/18.
//  Copyright © 2018 GEI. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Wall {
    
    
    private let x : CGFloat
    private let y : CGFloat
    private let position : CGPoint
    private let width : CGFloat
    private let maxHoles : CGFloat
    private let points : Int
    private let offset : CGFloat
    private let startAngle : CGFloat
    private let endAngle : CGFloat
    private let innerRadius : CGFloat
    private let outerRadius : CGFloat
    private let circlePath : UIBezierPath
    private let circleShape : SKShapeNode
    
    init(breaks maxBreaks: CGFloat, screenWidth screenW: CGFloat, screenHeight screenH: CGFloat) {
        self.x = 0
        self.y = 200
        self.position = CGPoint(x: x, y: y)
        self.width = 10
        self.maxHoles = maxBreaks
        self.points = 8
        self.offset = atan(min(screenW, screenH)/max(screenH, screenW))*2
        self.startAngle = 3*CGFloat.pi/2
        self.endAngle = 3*CGFloat.pi/2+offset
        self.innerRadius = CGFloat(sqrtf(Float(pow(screenW, 2) + pow(screenH, 2))))
        self.outerRadius = self.innerRadius + self.width
        self.circlePath = UIBezierPath()
        self.circlePath.addArc(withCenter: self.position, radius: self.innerRadius, startAngle: self.startAngle, endAngle: self.endAngle, clockwise: true)
        self.circlePath.addLine(to: CGPoint(x: self.outerRadius * cos(self.endAngle), y: self.outerRadius * sin(self.endAngle)))
        self.circlePath.addArc(withCenter: self.position, radius: self.outerRadius, startAngle: self.endAngle, endAngle: self.startAngle, clockwise: false)
        self.circlePath.close()
        self.circleShape = SKShapeNode(path: self.circlePath.cgPath)
        self.circleShape.strokeColor = SKColor.clear
        self.circleShape.fillColor = SKColor.white
        
        var bodies = [SKPhysicsBody]()
        var q = CGFloat(self.startAngle)
        for _ in 1...(self.points*2)
        {
            let parc = UIBezierPath()
            parc.move(to: CGPoint(x: self.innerRadius * cos(q) + self.x, y: self.innerRadius * sin(q) + self.y))
            parc.addLine(to: CGPoint(x: self.outerRadius * cos(q) + self.x, y: self.outerRadius * sin(q) + self.y))
            q += (self.offset/CGFloat(self.points))
            parc.addLine(to: CGPoint(x: self.outerRadius * cos(q) + self.x, y: self.outerRadius * sin(q) + self.y))
            parc.addLine(to: CGPoint(x: self.innerRadius * cos(q) + self.x, y: self.innerRadius * sin(q) + self.y))
            parc.close()
            bodies.append(SKPhysicsBody(polygonFrom: parc.cgPath))
        }
        
        self.circleShape.physicsBody = SKPhysicsBody(bodies: bodies)
        self.circleShape.physicsBody?.isDynamic = false
    }
    func getShape () -> SKShapeNode {
        return self.circleShape
    }
}
