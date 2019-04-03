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
    
    
    init(texture: SKTexture?, color: UIColor, size: CGSize, isCoin:Bool) {
        self.isCoin = isCoin
        
        let texture:SKTexture
        if isCoin {
            texture = SKTexture(imageNamed: "coin")
        } else {
            texture = SKTexture(imageNamed: "brick")
        }
        
        super.init(texture: texture, color: color, size: size)
        
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        self.physicsBody?.categoryBitMask = PhysicsCategory.Coin
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
