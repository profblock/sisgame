//
//  CoinBrick.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class CoinBrick: Contactable{
    
    var isCoin: Bool
    
    
    init(position:CGPoint, isCoin:Bool) {
        self.isCoin = isCoin
        
        //Dimensions for texture
        let color = UIColor.clear
        let size = CGSize(width: 400.0,height: 400.0)
        
        let texture:SKTexture
        if isCoin {
            texture = SKTexture(imageNamed: "Coin")
        } else {
            texture = SKTexture(imageNamed: "Brick")
        }
        
        super.init(texture: texture, color: color, size: size)
        if isCoin {
            self.physicsBody?.categoryBitMask = PhysicsCategory.Coin
            self.physicsBody?.collisionBitMask = PhysicsCategory.None
            self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        } else {
            self.physicsBody?.categoryBitMask = PhysicsCategory.Brick
            self.physicsBody?.collisionBitMask = PhysicsCategory.Ball
            self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        }
        self.position = position
    }
    
    
    override func toggle() {
        isCoin.toggle()
        if isCoin {
            self.texture = SKTexture(imageNamed: "Coin")
            self.physicsBody?.categoryBitMask = PhysicsCategory.Coin
            self.physicsBody?.collisionBitMask = PhysicsCategory.None
            self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        } else {
            self.texture = SKTexture(imageNamed: "Brick")
            self.physicsBody?.categoryBitMask = PhysicsCategory.Brick
            self.physicsBody?.collisionBitMask = PhysicsCategory.Ball
            self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
