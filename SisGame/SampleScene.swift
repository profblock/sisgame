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

    
    var ball : Player = Player()
    private var wall : Wall!
    private var previousPosition: CGPoint!
    private var chargeValue:CGFloat!
    private var startPoint:CGPoint?
    
    private var myCamera:Camera!
    private var objectsAreActivated = false;
    private var launcher : Launcher?
    private var isLauncherOnScreen = false
    private var staminaBar: StaminaBar!
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        staminaBar = StaminaBar(stamina: ball.stamina)
        

        let ground = Boundary()
        wall = Wall()
        
        
        // Add the two nodes to the scene
        self.addChild(self.ball)
        self.addChild(self.wall!)
        self.addChild(ground)
        
        myCamera = Camera()
        self.camera = myCamera
        self.addChild(myCamera)
        myCamera.initHelper();
        myCamera.addChild(staminaBar)
        staminaBar.initHelper()
        launcher = Launcher(mainNode: myCamera)
        
    }
    
    override func didFinishUpdate() {
        self.wall!.moveWall()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches started")
            startPoint = touch.location(in: self.myCamera)
            print("Startpoint is \(startPoint)")
            print(myCamera.leftScreen.contains(touch.location(in: self.myCamera)))

            if(myCamera.pauseButton.contains(touch.location(in: self.myCamera))){
                print("Pause")
                if(self.isPaused == false){
                    self.isPaused = true
                } else{
                    self.isPaused = false
                }
                
            } else if(myCamera.leftScreen.contains(touch.location(in: self.myCamera))){
                // Only allow launching if we have stamina
                if ball.stamina! > CGFloat(0) {
                    //lightPause()
                    launcher?.create(tap: touch.location(in: self.myCamera), stamina: ball.stamina!)
                    isLauncherOnScreen = true;
                }
            } else if(myCamera.rightScreen.contains(touch.location(in: self.myCamera))){
                if(self.objectsAreActivated == false){
                    self.objectsAreActivated = true
                    myCamera.rightScreen.strokeColor = .blue
                } else if(self.objectsAreActivated == true){
                    self.objectsAreActivated = false
                    myCamera.rightScreen.strokeColor = .purple
                }
            }
            

        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches moved")
            if(myCamera.leftScreen.contains(self.startPoint!) && isLauncherOnScreen == true){
                print("x:\(touch.location(in: self.view).x),y:\(touch.location(in: self.view).y) ")
                launcher?.repaint(curTap: touch.location(in: self.myCamera), stamina: ball.stamina!)
                //ball.stamina = ball.stamina - 1
                if(ball.stamina! < CGFloat(0)) {
                    ball.stamina = 0
                    launcher?.destroy()
                    isLauncherOnScreen = false
                    //normalSpeed()
                }
                
                
            }
            
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let startPoint = self.startPoint{
            if(myCamera.pauseButton.contains(touch.location(in: self.myCamera))){
                print("Pause")
            } else if(myCamera.leftScreen.contains(touch.location(in: self.myCamera))){
                //physicsWorld.speed = 1
                if(myCamera.leftScreen.contains(self.startPoint!) && isLauncherOnScreen){
                    //normalSpeed()
                    launcher?.destroy()
                    isLauncherOnScreen = false;
                    
                    let endPoint = touch.location(in: self.myCamera)
                    
                    ball.launchBall(startPoint: startPoint, endPoint: endPoint)
                }
                
            } else if(myCamera.rightScreen.contains(touch.location(in: self.myCamera))){
                
                
            }
            if(isLauncherOnScreen == true){
                //normalSpeed()
                launcher?.destroy()
                isLauncherOnScreen = false;
            }
            
        }
        
    }
    
    override func didSimulatePhysics() {
        myCamera.trackBall(ball: ball)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (isLauncherOnScreen == false){
            if(ball.stamina < ball.maxStamina){
                ball.stamina += 0.5
            }
        } else {
            ball.stamina -= 0.5
            launcher?.repaint(stamina: ball.stamina)
        }
        staminaBar.changeStamina(newStamina: ball.stamina)
    }
    
    
    
//    override func didFinishUpdate() {
//        let xPos = self.size.width/2.0 - ball!.position.x
//        let yPos = self.size.height/2.0 - ball!.position.y
//        mainNode?.position = CGPoint(x:xPos,y:yPos)
//    }
    
}
