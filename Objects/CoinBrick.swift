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
        let size = CGSize(width: 40.0,height: 40.0)
        
        let texture:SKTexture
        if isCoin {
            texture = SKTexture(imageNamed: "Coin")
        } else {
            texture = SKTexture(imageNamed: "Brick")
        }
        
        super.init(texture: texture, color: color, size: size)
        self.position = position
        
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        self.physicsBody?.categoryBitMask = PhysicsCategory.Coin
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    override func toggle() {
        if isCoin {
            self.texture = SKTexture(imageNamed: "Brick")
        } else {
            self.texture = SKTexture(imageNamed: "Coin")
        }
        
        isCoin.toggle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
