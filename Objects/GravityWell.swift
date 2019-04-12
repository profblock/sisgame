//
//  GravityWell.swift
//  SisGame
//
//  Created by Aaron Block on 4/12/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class GravityWell: Contactable {
    
    var isOn: Bool!
    
    init(position:CGPoint, isOn : Bool){
        
        self.isOn = isOn
        
        //Dimensions for texture
        let color = UIColor.clear
        //Eventually, enimies will need different sizes but for now the same size.
        let size = CGSize(width: 50.0,height: 50.0)
        
        let texture:SKTexture
        
        texture = isOn ? SKTexture(imageNamed: "Enemy") : SKTexture(imageNamed: "EnemyOff")
        super.init(texture: texture, color: color, size: size)
        
        //We are going to need the texture to be bigger than the physics body
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.GravityWell
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        // no collision for gravity wells
        
//        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Setting texture and physicsBody according to whether or
        // not this Enemy starts as "on"
        if isOn {
            //self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        } else {
            //self.physicsBody?.categoryBitMask = PhysicsCategory.None
        }
        
        self.position = position
        
        let shield = SKFieldNode.radialGravityField()
        shield.strength = 5
        shield.region = SKRegion(radius: 100)
        shield.falloff = 4
        self.addChild(shield)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
