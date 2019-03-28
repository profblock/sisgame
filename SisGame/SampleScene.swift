//
//  SampleScene.swift
//  SampleSpriteKit
//
//  Created by Aaron Block on 2/4/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball   : UInt32 = 0b1       // 1
    static let Ground: UInt32 = 0b10      // 2
    static let Coin: UInt32 = 0b100      // 4
    static let Wall: UInt32 = 0b1000      // 8
    static let Field: UInt32 = 0b10000      // 16
}

//SKScenes are the "view" equivalant for sprite kit.
class SampleScene: SKScene, SKPhysicsContactDelegate {
    
    private var mainNode:SKNode?

    
    var ball : Player = Player()
    private var deathWall : Wall!
    private var safeWall : Wall!
    private var previousPosition: CGPoint!
    private var chargeValue:CGFloat!
    private var startPoint:CGPoint?
    
    private var myCamera:Camera!
    private var objectsAreActivated = false;
    private var launcher : Launcher?
    private var isLauncherOnScreen = false
    private var staminaBar: StaminaBar!
    private var score: CGFloat?
    let scoreScalingFactor: CGFloat = 0.01
    
    //Change to false enable death wall
    let debug : Bool = true
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        score = 0
        staminaBar = StaminaBar(stamina: ball.stamina)
        

        let ground = Boundary()
        deathWall = Wall(startX: -300.0, color: .red, doesKill: true)
        safeWall = Wall(startX: 0.0, color: .blue, doesKill: false)
        
        // Add the two nodes to the scene
        self.addChild(self.ball)
        self.addChild(self.deathWall!)
        self.addChild(self.safeWall!)
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
        self.deathWall!.moveWall()
        // Updating score label in UI
        self.myCamera.updateScore(score: score!)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches started")
            startPoint = touch.location(in: self.myCamera)
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
                if ball.stamina > CGFloat(0) {
                    //lightPause()
                    launcher?.create(tap: touch.location(in: self.myCamera), stamina: ball.stamina)
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
                launcher?.repaint(curTap: touch.location(in: self.myCamera), stamina: ball.stamina)
                //ball.stamina = ball.stamina - 1
                if(ball.stamina < CGFloat(0)) {
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
        let staminaDecreaseRate : CGFloat = 0.5
        let staminaIncreaseRate : CGFloat = 0.5
        if (isLauncherOnScreen == false){
            if(ball.stamina < ball.maxStamina){
                ball.stamina += staminaIncreaseRate
            }
        } else {
            ball.stamina -= staminaDecreaseRate
            launcher?.repaint(stamina: ball.stamina)
        }
        staminaBar.changeStamina(newStamina: ball.stamina)
        
        // Updating score value, based on distance travelled and scaling factor
        score = CGFloat(ball.calculateDistanceTravelled() * scoreScalingFactor).rounded()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //        print("A collision")
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Coin != 0)) {
            print("Contact")
            // _ here is the ball, but we never reference it
            if let _ = firstBody.node as? SKShapeNode, let
                coin = secondBody.node as? SKShapeNode {
                //                print("A collision between the ball and coin")
                coin.removeFromParent()
                return // No need for more collision checks if we accomplished our goal
                
                //                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Wall != 0)) {
            //            print("Ball hit wall")
            if(debug == false) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        }
    }
    
    
//    override func didFinishUpdate() {
//        let xPos = self.size.width/2.0 - ball!.position.x
//        let yPos = self.size.height/2.0 - ball!.position.y
//        mainNode?.position = CGPoint(x:xPos,y:yPos)
//    }
    
}
