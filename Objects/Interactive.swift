//
//  Interactive.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class Interactive: SKSpriteNode {
    
    var image:SKSpriteNode!
    var categoryBitMask: UInt32!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        fatalError("init(coder:) has not been implemented, please use init()")
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    func isTouched()-> Bool{
        fatalError("Abstact Method, must be overrided")
    }
    
}
