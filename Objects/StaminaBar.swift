//
//  StaminaBar.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class StaminaBar: Noninteractive{
    var p:Player!
    var stamina: CGFloat!
    var barOutline:SKShapeNode!
    var barInline:SKShapeNode!
    var screenRegionXBound: CGFloat!
    var screenRegionYBound: CGFloat!
    
    init(stamina:CGFloat) {
        self.stamina = stamina
        super.init()
        barOutline = SKShapeNode()
        barInline = SKShapeNode()
        
        self.addChild(barOutline)
        self.addChild(barInline)
        
    }
    
    func initHelper(){
        let sisScene = self.scene! as! SampleScene
        stamina = { return sisScene.ball.stamina! }()
        screenRegionXBound = self.scene!.view!.bounds.maxX
        screenRegionYBound = self.scene!.view!.bounds.maxY
        let staminaVertOffset : CGFloat = 30.0
        let staminaHorizOffset : CGFloat = 0.0
        let maxBarWidth: CGFloat = 100.0
    
        barOutline.path = CGPath(rect: CGRect(x: -maxBarWidth, y: (screenRegionYBound/2) - staminaVertOffset, width: maxBarWidth*2, height: 30), transform: nil)
        barOutline.fillColor = .blue
        barInline.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
        barInline.fillColor = .red
        
    }
    
    func changeStamina(newStamina:CGFloat){
        let staminaVertOffset : CGFloat = 30.0
        self.stamina = newStamina
        barInline.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
