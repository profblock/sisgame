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
    var maxStamina: CGFloat = 100
    var stamina: CGFloat
    var distanceTravelled: CGFloat = 0
    
    convenience init() {
        // convenience constructer
        let texture = SKTexture(imageNamed: "Player")
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
        
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        self.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        self.physicsBody?.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Brick | PhysicsCategory.Enemy | PhysicsCategory.GravityWell
        self.physicsBody?.fieldBitMask = PhysicsCategory.Field
        
        
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
    
    private static func magnitudeAndDirection(startPoint:CGPoint, endPoint:CGPoint) -> (CGFloat,(CGFloat,CGFloat)){
        let dx = startPoint.x - endPoint.x
        let dy = startPoint.y - endPoint.y
        let mag = pow(pow(dx, 2.0) + pow(dy, 2.0),0.5)
        let maxPullDistance = CGFloat(50.0) //made this up
        let cappedMag = mag <= maxPullDistance ? mag : maxPullDistance
        
        return (cappedMag, (dx/mag,dy/mag))
    }
    

    static func projectedStamina(startPoint:CGPoint, endPoint:CGPoint)->CGFloat {
        let staminaScalingFactor : CGFloat = 0.5
        let (distance, _) = Player.magnitudeAndDirection(startPoint: startPoint, endPoint: endPoint)
        return distance * staminaScalingFactor
    }
    
    
    func launchBall(startPoint:CGPoint, endPoint:CGPoint){
        
        let projectedStamina = Player.projectedStamina(startPoint: startPoint, endPoint: endPoint)
        
        if (projectedStamina <= stamina) {
            let (magnitude, (dx,dy)) = Player.magnitudeAndDirection(startPoint: startPoint, endPoint: endPoint)
            let velocityScalingFactor = CGFloat(2.0) //made this up
            
            let newDX = dx*magnitude * velocityScalingFactor
            let newDY = dy*magnitude * velocityScalingFactor
            
            let charge = CGVector(dx: newDX, dy: newDY)
            self.physicsBody?.applyImpulse(charge)
            self.stamina -= projectedStamina
        }

        
    }
    
    func calculateDistanceTravelled() -> CGFloat {
        
        // Makes sure that distanceTravelled
        // never goes backwards
        if(position.x > distanceTravelled) {
            distanceTravelled = position.x
        }
        
        return distanceTravelled
    }
    
    
}
