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
    
    
    var stamina: Int!
    
    override init() {
        super.init()
        let tempPath = CGMutablePath()
        tempPath.addArc(center: CGPoint.zero, radius: 32.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        self.path = tempPath
        self.lineWidth = 1
        self.fillColor = .white
        self.fillTexture = SKTexture(imageNamed: "sface.png")
        self.position = CGPoint(x: 320, y: 320)
        self.physicsBody = SKPhysicsBody(polygonFrom: self.path!)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.friction = 1.0
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func launchBall(){
        // TODO: launchBall
        
    }
    
    
}
