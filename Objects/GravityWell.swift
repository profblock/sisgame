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
    let gravityPullField = SKFieldNode.radialGravityField()
    let gravityPushField = SKFieldNode.radialGravityField()
    
    init(position:CGPoint, isOn : Bool){
        
        self.isOn = isOn
        
        let color = UIColor.clear
        //Dimensions for texture
        let size = CGSize(width: 50.0,height: 50.0)

        let texture:SKTexture
        texture = isOn ? SKTexture(imageNamed: "pullHole") : SKTexture(imageNamed: "pushHole")
        
       
        
        
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
        
        
        gravityPullField.strength = 7
        gravityPullField.region = SKRegion(radius: 800)
        gravityPullField.falloff = 1
        
        gravityPushField.strength = -7
        gravityPushField.region = SKRegion(radius: 800)
        gravityPushField.falloff = 1
        
        if isOn {
            self.addChild(gravityPullField)
        } else {
            self.addChild(gravityPushField)
        }
        
        self.position = position
    }
    
    override func toggle() {
        isOn.toggle()
        if isOn {
            self.texture = SKTexture(imageNamed: "pullHole")
            gravityPushField.removeFromParent()
            self.addChild(gravityPullField)
            
        } else {
            self.texture = SKTexture(imageNamed: "pushHole")
            gravityPullField.removeFromParent()
            self.addChild(gravityPushField)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
