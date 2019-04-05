//
//  Wall.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class Wall: SKShapeNode {

    var distanceAway:Int!
    var isMoving = true
    let maxDistance: CGFloat = 1000.0
    
    
    override convenience init() {
        self.init(startX : 0.0, color : UIColor.red, doesKill : true)
    }
    
    init(startX : CGFloat, color : UIColor, doesKill : Bool) {
        
        super.init()
        
        self.path = CGPath(rect: CGRect(x: startX, y: 0, width: 1, height: 10000), transform: nil)
        
        
        self.lineWidth = 5
        self.physicsBody = SKPhysicsBody(edgeChainFrom: self.path!)
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 1.0
        self.strokeColor = color
        if(doesKill) {
            print("Oh boy, here I go killin again")
            self.physicsBody?.categoryBitMask = PhysicsCategory.Wall
            self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        } else {
            self.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveWall(currentPositionOfPlayer:CGPoint){
        if isMoving {
            self.position.x += 1
            if currentPositionOfPlayer.x - maxDistance  > self.position.x{
                self.position.x = currentPositionOfPlayer.x - maxDistance
            }
        }
        
    }
    
    
}
