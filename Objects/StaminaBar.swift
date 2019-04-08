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
    var emptyBar:SKShapeNode!
    var actualBar:SKShapeNode!
    var screenRegionXBound: CGFloat!
    var screenRegionYBound: CGFloat!
    var projectedBar:SKShapeNode!
    
    let emptyColor : UIColor  = .gray
    let projectedColor : UIColor = .blue
    let actualColor : UIColor = .red
    
    init(stamina:CGFloat) {
        self.stamina = stamina
        super.init()
        emptyBar = SKShapeNode()
        actualBar = SKShapeNode()
        projectedBar = SKShapeNode()
        
        //Order matters here because empty is the background, projected is on top and actual is the bottom
        self.addChild(emptyBar)
        self.addChild(projectedBar)
        self.addChild(actualBar)
        
        

        
    }
    
    func initHelper(){
        let sisScene = self.scene! as! SampleScene
        stamina = { return sisScene.ball.stamina }()
        screenRegionXBound = self.scene!.view!.bounds.maxX
        screenRegionYBound = self.scene!.view!.bounds.maxY
        let staminaVertOffset : CGFloat = 30.0
        let staminaHorizOffset : CGFloat = 0.0
        let maxBarWidth: CGFloat = 100.0
    
        emptyBar.path = CGPath(rect: CGRect(x: -maxBarWidth, y: (screenRegionYBound/2) - staminaVertOffset, width: maxBarWidth*2, height: 30), transform: nil)
        emptyBar.fillColor = emptyColor
        
        projectedBar.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
        projectedBar.fillColor = projectedColor
        
        actualBar.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
        actualBar.fillColor = actualColor
        
        
        
    }
    
    func changeStamina(newStamina:CGFloat){
        let staminaVertOffset : CGFloat = 30.0
        self.stamina = newStamina
        actualBar.path = CGPath(rect: CGRect(x: -stamina, y: (screenRegionYBound/2) - staminaVertOffset, width: stamina*2, height: 30), transform: nil)
    }
    
    func startProjection(){
        projectedBar.path = actualBar.path
    }
    
    func endProjection(){
        
    }
    
//    func projectsStamina(newStamina:CGFloat){
//        let scale = SKAction.scale(to: 0.1, duration: 0.5)
//        let fade = SKAction.fadeOut(withDuration: 0.5)
//        let sequence = SKAction.sequence([scale, fade])
//        projectedBar.run(sequence)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
