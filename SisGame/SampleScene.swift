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
    private var previousPosition: CGPoint!
    private var chargeValue:CGFloat!
    private var startPoint:CGPoint?
    
    private var myCamera:Camera!
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        mainNode = SKNode()
        chargeValue = 0.0
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        var hexagonPoints = [CGPoint(x: 0, y: -20),
                             CGPoint(x: -19, y: -6),
                             CGPoint(x: -12, y: 16),
                             CGPoint(x: 12, y: 16),
                             CGPoint(x: 19, y: -6),
                             CGPoint(x: 0, y: -20)]
        
        //self.ball = SKShapeNode(ellipseOf: CGSize(width: w, height: w))
        //self.ball = SKShapeNode(points: &hexagonPoints, count: 6)
        self.ball = Player()
        previousPosition = ball!.position
        

        // Create the ground node and physics body
        var splinePoints = [CGPoint(x: 0, y: 500),
                            CGPoint(x: 100, y: 50),
                            CGPoint(x: 400, y: 110),
                            CGPoint(x: 640, y: 20)]
        
        let ground = Boundary()
        let wall = Wall()
        
        
        // Add the two nodes to the scene
        mainNode?.addChild(self.ball!)
        mainNode?.addChild(wall)
        mainNode?.addChild(ground)
        
        self.addChild(mainNode!)
        //self.addChild(self.ball!)
        myCamera = Camera()
        self.camera = myCamera
        self.addChild(myCamera)
        
    }
    
    func centerOnBall() {
        //Trying something here that should smooth out the camera motion
        //move camera using lerp
        //http://www.learn-to-code-london.co.uk/blog/2016/04/smoother-camera-motion-in-spritekit-using-lerp/
        guard ball != nil else {
            return
        }
        //TODO: Update constants with real values
        let currentPosition = ball!.position
        let x = (weightedFactor(previous: previousPosition.x, current: currentPosition.x, currentWeight: 0.03) + 200)
        let y = (weightedFactor(previous: previousPosition.y, current: currentPosition.y, currentWeight: 0.03) + 75)
        previousPosition = currentPosition;
        
        self.camera?.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 0.01))
        
    }
    
    /* This is allso called a propertial intergral controller (PI)
     * It's a very dumb one because it only works on one data point (the previous).
     * This weights the preivous value some fraction (1-currentWeight) and the current (currentWeight)
     * if weight is less than 0 or greater than 1, then just return current
     */
    func weightedFactor(previous: CGFloat, current:CGFloat, currentWeight:CGFloat)->CGFloat{
        if currentWeight >= 0 && currentWeight <= 1.0 {
            return (1 - currentWeight) * previous + currentWeight * current;
        } else {
            return current
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches started")
            startPoint = touch.location(in: self)
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches moved")
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let startPoint = self.startPoint{
            print("Touches ENDED")
            
            let endPoint = touch.location(in: self)
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")

            let factor : CGFloat = 1.0
            let charge = CGVector(dx: factor*(startPoint.x - endPoint.x), dy: factor*(startPoint.y - endPoint.y))
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
