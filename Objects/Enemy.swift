//
//  Enemy.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class Enemy: Contactable{
    
    
    var path1:Any!
    var isOn: Bool!
    
    enum TypeOfEnemy {
        case basic
    }
    var typeOfEnemy : TypeOfEnemy
    
    init(typeOfEnemy:TypeOfEnemy, position:CGPoint, isOn : Bool){
        self.typeOfEnemy = typeOfEnemy
        self.isOn = isOn
        //Dimensions for texture
        let color = UIColor.clear
        //Eventually, enimies will need different sizes but for now the same size.
        let size = CGSize(width: 100.0,height: 100.0)
        
        let texture:SKTexture
        
        texture = isOn ? SKTexture(imageNamed: "Enemy") : SKTexture(imageNamed: "EnemyOff")
        // Commented out for now in exchange for enemy toggle
//        switch typeOfEnemy {
//        case .basic:
//            texture = SKTexture(imageNamed: "Enemy")
//        }
        
        super.init(texture: texture, color: color, size: size)
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        self.physicsBody?.collisionBitMask = PhysicsCategory.None

        // Setting texture and physicsBody according to whether or
        // not this Enemy starts as "on"
        if isOn {
            self.texture = SKTexture(imageNamed: "Enemy")
            self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        } else {
            self.texture = SKTexture(imageNamed: "EnemyOff")
            self.physicsBody?.categoryBitMask = PhysicsCategory.None
        }
        
        self.position = position
        
        // Code for moving the enemy along a path, used in previous iterations
//        let primaryDirection = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 2.0)
//        let reverseDirection = primaryDirection.reversed()
//        self.run(SKAction.repeatForever(SKAction.sequence([primaryDirection, reverseDirection])))
    }
    

    // Toggles between being on/off, changes textures
    // and determines whether the ball will collide or not
    override func toggle() {
        isOn.toggle()
        if isOn {
            self.texture = SKTexture(imageNamed: "Enemy")
            self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        } else {
            self.texture = SKTexture(imageNamed: "EnemyOff")
            self.physicsBody?.categoryBitMask = PhysicsCategory.None
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
