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
    
    override init() {
        super.init()
        
        let upperBoundPoint = CGPoint(x: 0, y: 10000)
        var linePoints = [CGPoint(x: 0, y: 0), upperBoundPoint]
        
        self.path = CGPath(rect: CGRect(x: 0, y: 0, width: 1, height: 10000), transform: nil)
        
        
        self.lineWidth = 5
        self.physicsBody = SKPhysicsBody(edgeChainFrom: self.path!)
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 1.0
        self.strokeColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
