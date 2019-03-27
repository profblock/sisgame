//
//  Player.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit


class Player:Interactive{
    // TODO: Stamina
    
    
    var maxStamina: CGFloat = 100
    var stamina: CGFloat
    var projectedStaminaLoss : CGFloat = 0.0
    
    
    convenience init() {
        // convenience constructer
        let texture = SKTexture(imageNamed: "sface.png")
        self.init(texture: texture, color: .white, size: CGSize(width: 40, height: 40))

    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.stamina = maxStamina
        super.init(texture: texture, color: color, size: size)
        
        
        self.color = .white
        self.position = CGPoint(x: 320, y: 320)

        // Add the physicsBody and configure it's properties
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2.0)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.friction = 1.0
        
        // Make a SKShapeNode that will act as the outline of Player
        let shapeNode = SKShapeNode(circleOfRadius: self.size.width/2.0)
        shapeNode.lineWidth = 1
        shapeNode.strokeColor = .white
        shapeNode.fillColor = .clear
        addChild(shapeNode)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func launchBall(startPoint:CGPoint, endPoint:CGPoint){
        // TODO: launchBall
        let dx = startPoint.x - endPoint.x
        let dy = startPoint.y - endPoint.y
        let mag = pow(pow(dx, 2.0) + pow(dy, 2.0),0.5)
        let minVel = CGFloat(20.0) //made this up
        let maxVel = CGFloat(50.0) //made this up
        let scalingFactor = CGFloat(0.5) //made this up
        let uncappedNewMag = scalingFactor*mag + minVel
        let newVelMag = uncappedNewMag <= maxVel ? uncappedNewMag : maxVel
        
        let newDX = dx/mag * newVelMag
        let newDY = dx/mag * newVelMag
        
        let charge = CGVector(dx: newDX, dy: newDY)
        
        self.physicsBody?.applyImpulse(charge)
    }
    
    
}
