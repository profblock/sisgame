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
    
    
    var stamina: Int! // Not implemented
    
    convenience init() {
        // convenience constructer
        
        let texture = SKTexture(imageNamed: "sface.png")
        self.init(texture: texture, color: .white, size: CGSize(width: 40, height: 40))
        
        
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
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
    
    
    
    func launchBall(){
        // TODO: launchBall
        
    }
    
    
}
