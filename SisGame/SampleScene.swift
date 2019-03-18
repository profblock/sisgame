//
//  SampleScene.swift
//  SampleSpriteKit
//
//  Created by Aaron Block on 2/4/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit



//SKScenes are the "view" equivalant for sprite kit.
class SampleScene: SKScene {
    private var mainNode:SKNode?

    // Shape node might be approriate for ball and maybe approriate for other shapes, but
    // too many can impact performance
    private var ball : Player?
    private var wall : Wall?
    private var previousPosition: CGPoint!
    private var chargeValue:CGFloat!
    private var startPoint:CGPoint?
    
    private var myCamera:Camera!
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        mainNode = SKNode()
        
        self.ball = Player()
        

        let ground = Boundary()
        wall = Wall()
        
        
        // Add the two nodes to the scene
        mainNode?.addChild(self.ball!)
        mainNode?.addChild(self.wall!)
        mainNode?.addChild(ground)
        
        self.addChild(mainNode!)
        //self.addChild(self.ball!)
        myCamera = Camera()
        self.camera = myCamera
        self.addChild(myCamera)
        
    }
    
    override func didFinishUpdate() {
        self.wall!.moveWall()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches started")
            startPoint = touch.location(in: self.view)
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches moved")
            print("x:\(touch.location(in: self.view).x),y:\(touch.location(in: self.view).y) ")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let startPoint = self.startPoint{
            
            //physicsWorld.speed = 1
            //normalSpeed()
            
            let endPoint = touch.location(in: self.view)
            let dx = startPoint.x - endPoint.x
            let dy = startPoint.y - endPoint.y
            let mag = pow(pow(dx, 2.0) + pow(dy, 2.0),0.5)
            let minVel = CGFloat(20.0) //made this up
            let maxVel = CGFloat(50.0) //made this up
            let scalingFactor = CGFloat(0.5) //made this up
            let uncappedNewMag = scalingFactor*mag + minVel
            let newVelMag = uncappedNewMag <= maxVel ? uncappedNewMag : maxVel
            
            let newDX = dx/mag * newVelMag
            let newDY = dx/mag * newVelMag
            
            
            
            let charge = CGVector(dx: newDX, dy: newDY)
            
            
            
            ball?.physicsBody?.applyImpulse(charge)
        }
        
    }
    
    override func didSimulatePhysics() {
        myCamera.trackBall(ball: ball!)
    }
    
    
    
//    override func didFinishUpdate() {
//        let xPos = self.size.width/2.0 - ball!.position.x
//        let yPos = self.size.height/2.0 - ball!.position.y
//        mainNode?.position = CGPoint(x:xPos,y:yPos)
//    }
    
}
