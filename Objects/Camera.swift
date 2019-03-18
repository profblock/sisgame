//
//  Camera.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class Camera: SKCameraNode{
    
    var previousPosition: CGPoint!
    
    override init() {
        super.init()
        previousPosition = self.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trackBall(ball: Player){
        //Trying something here that should smooth out the camera motion
        //move camera using lerp
        //http://www.learn-to-code-london.co.uk/blog/2016/04/smoother-camera-motion-in-spritekit-using-lerp/
        //TODO: Update constants with real values
        let currentPosition = ball.position
        
        let x = (weightedFactor(previous: previousPosition.x, current: currentPosition.x, currentWeight: 0.03) + 200)
        let y = (weightedFactor(previous: previousPosition.y, current: currentPosition.y, currentWeight: 0.03) + 75)
        previousPosition = currentPosition;
        
        self.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 0.01))
    }
    
    func weightedFactor(previous: CGFloat, current:CGFloat, currentWeight:CGFloat)->CGFloat{
        if currentWeight >= 0 && currentWeight <= 1.0 {
            return (1 - currentWeight) * previous + currentWeight * current;
        } else {
            return current
        }
        
    }
    
    
    func zoomOut(){
        
    }
    
    func zoomIn(){
        
        
    }
    
    
    
}
