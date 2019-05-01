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
        let sizeOfCenterAt200TextureWidth = CGFloat(50)
        let size = CGSize(width: 200.0,height: 200.0)

        let texture:SKTexture
        texture = isOn ? SKTexture(imageNamed: "pullHole") : SKTexture(imageNamed: "pushHole")
        
       
        
        
        super.init(texture: texture, color: color, size: size)
        
        //We are going to need the texture to be bigger than the physics body
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: sizeOfCenterAt200TextureWidth)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.GravityWell
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        // no collision for gravity wells
        
//        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Setting texture and physicsBody according to whether or
        // not this Enemy starts as "on"
        
        
        gravityPullField.strength = 15
        gravityPullField.region = SKRegion(radius: 400)
        gravityPullField.falloff = 0
        
        gravityPushField.strength = -15
        gravityPushField.region = SKRegion(radius: 400)
        gravityPushField.falloff = 0
        
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
