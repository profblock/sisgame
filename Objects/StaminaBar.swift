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
    var projStamina:SKShapeNode!
    
    init(stamina:CGFloat) {
        self.stamina = stamina
        super.init()
        barOutline = SKShapeNode()
        barInline = SKShapeNode()
        projStamina = SKShapeNode()
        
        self.addChild(barOutline)
        self.addChild(barInline)
        self.addChild(projStamina)
        

        
    }
    
    func initHelper(){
        let sisScene = self.scene! as! SampleScene
        stamina = { return sisScene.ball.stamina }()
        screenRegionXBound = self.scene!.view!.bounds.maxX
        screenRegionYBound = self.scene!.view!.bounds.maxY
        let staminaVertOffset : CGFloat = 30.0
        let staminaHorizOffset : CGFloat = 0.0
        let maxBarWidth: CGFloat = 100.0
    
        barOutline.path = CGPath(rect: CGRect(x: -maxBarWidth, y: (screenRegionYBound/2) - staminaVertOffset, width: maxBarWidth*2, height: 30), transform: nil)
        barOutline.fillColor = .blue
        barInline.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
        barInline.fillColor = .red
        
        projStamina.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
        barInline.fillColor = .gray
        
    }
    
    func changeStamina(newStamina:CGFloat){
        let staminaVertOffset : CGFloat = 30.0
        self.stamina = newStamina
        barInline.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
    }
    
    func projectsStamina(newStamina:CGFloat){
        let scale = SKAction.scale(to: 0.1, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let sequence = SKAction.sequence([scale, fade])
        projStamina.run(sequence)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
