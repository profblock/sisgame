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
    static let Brick: UInt32 = 0b100000      // 32
    static let Enemy: UInt32 = 0b1000000      // 64
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
    private var ground: Boundary?
    private let normalGravity = CGVector(dx: 0, dy: -9.8)
    private let noGravity = CGVector(dx: 0, dy: 0)
    private var oldSpeed = CGVector.zero
    
    
    var coin:CoinBrick!
    var brick:CoinBrick!
    var enemy:Enemy!
    private var par1:ParallaxBackground?
    private var par2:ParallaxBackground?
    
    //Change to false enable death wall
    let debug : Bool = true
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        score = 0
        staminaBar = StaminaBar(stamina: ball.stamina)
        
        par1 = ParallaxBackground(spriteName: "Parallax-Diamonds-1", gameScene: self, heightOffset: 0, zPosition: -1)
        par2 = ParallaxBackground(spriteName: "Parallax-Diamonds-2", gameScene: self, heightOffset: 0, zPosition: -2)
//        self.addChild(par1!.sprite!)
//        self.addChild(par1!.spriteNext!)
//        self.addChild(par2!.sprite!)
//        self.addChild(par2!.spriteNext!)

        ground = Boundary()
        deathWall = Wall(startX: -300.0, color: .red, doesKill: true)
        safeWall = Wall(startX: 0.0, color: .blue, doesKill: false)
        
        // Add the two nodes to the scene
        self.addChild(self.ball)
        self.addChild(self.deathWall!)
        self.addChild(self.safeWall!)
        self.addChild(ground!)
        
        coin = CoinBrick(position:CGPoint(x: ball.position.x+200, y: ball.position.y+200), isCoin: true)
        brick = CoinBrick(position:CGPoint(x: ball.position.x+200, y: ball.position.y-200),isCoin: false)
        
        self.addChild(coin)
        self.addChild(brick)
        
        let path = CGMutablePath()
        
        let enemyStartPoint = CGPoint(x: ball.position.x+100, y: ball.position.y+100)
        path.move(to: CGPoint(x:0,y:0))
        let enemyEndPoint = CGPoint(x: ball.position.x+300, y: ball.position.y+100)
        path.addLine(to: CGPoint(x:100,y:100))
        enemy = Enemy(typeOfEnemy: Enemy.TypeOfEnemy.basic,position:enemyStartPoint, path: path )
        self.addChild(enemy)
        
        myCamera = Camera()
        self.camera = myCamera
        self.addChild(myCamera)
        myCamera.initHelper()
        myCamera.addChild(staminaBar)
        staminaBar.initHelper()
        launcher = Launcher(mainNode: myCamera)
        
    }
    
    override func didFinishUpdate() {
        self.deathWall!.moveWall(currentPositionOfPlayer: ball.position)
        // Updating score label in UI
        self.myCamera.updateScore(score: score!)
        par1?.updateCamera(camera: self.myCamera)
        
        // TODO: Change from 300 to double of the width of the screen
        if(ball.position.x >= ground!.prevFinalPoint!.x - 300) {
            ground?.addSegment()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            startPoint = touch.location(in: self.myCamera)
            

            if(myCamera.pauseButton.contains(touch.location(in: self.myCamera))){

                if(self.isPaused == false){
                    self.isPaused = true
                } else{
                    self.isPaused = false
                }
                
            } else if(myCamera.leftScreen.contains(touch.location(in: self.myCamera))){
                // Only allow launching if we have stamina
                if ball.stamina > CGFloat(0) {
                    lightPause()
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
                coin.toggle()
                brick.toggle()
            }
            

        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            if(myCamera.leftScreen.contains(self.startPoint!) && isLauncherOnScreen == true){
                launcher?.repaint(curTap: touch.location(in: self.myCamera), stamina: ball.stamina)
                //ball.stamina = ball.stamina - 1
                if(ball.stamina < CGFloat(0)) {
                    ball.stamina = 0
                    launcher?.destroy()
                    isLauncherOnScreen = false
                    normalSpeed()
                }
                
                
            }
            
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let startPoint = self.startPoint{
            if(myCamera.leftScreen.contains(touch.location(in: self.myCamera))){
                //physicsWorld.speed = 1
                if(myCamera.leftScreen.contains(self.startPoint!) && isLauncherOnScreen){
                    normalSpeed()
                    launcher?.destroy()
                    isLauncherOnScreen = false;
                    
                    
                    let endPoint = touch.location(in: self.myCamera)
                    
                    ball.launchBall(startPoint: startPoint, endPoint: endPoint)
                }
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
            // _ here is the ball, but we never reference it
            print("The ball came into contact with a coin")
            secondBody.node?.removeFromParent()
            //may end up doing something with the coin, but otherwise. No
            //Code is incorrect because they aren't skshapenode
//            if let _ = firstBody.node as? SKShapeNode, let
//                coin = secondBody.node as? SKShapeNode {
//                coin.removeFromParent()
//                return // No need for more collision checks if we accomplished our goal
//            }
        }
        
        // 3
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Brick != 0)) {
            print("The ball came into contact with a brick")
            // _ here is the ball, but we never reference it
            //may end up doing something with the brick, but otherwise. No
            //Code is incorrect because they aren't skshapenode
//            if let _ = firstBody.node as? SKShapeNode, let
//                coin = secondBody.node as? SKShapeNode {
//                print("hmm")
//                return // No need for more collision checks if we accomplished our goal
//            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Enemy != 0)) {
            print("The ball came into contact with an Enemy")
            // _ here is the ball, but we never reference it
            //may end up doing something with the brick, but otherwise. No
            //Code is incorrect because they aren't skshapenode
            //            if let _ = firstBody.node as? SKShapeNode, let
            //                coin = secondBody.node as? SKShapeNode {
            //                print("hmm")
            //                return // No need for more collision checks if we accomplished our goal
            //            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Wall != 0)) {
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
    
    //This kills Gravity and decreaes the speed to a crall. This SHOULD work for SHORT times as long as you don't collide with anything.
    //TODO: Find better approach or fix this when collisions occur (old velocity will be very wrong in that case
    func lightPause(){
        self.camera?.run(SKAction.scale(by: 1.4, duration: 5.0))
        
//
//        guard ball.physicsBody?.velocity != nil else {
//            return
//        }
//        oldSpeed = ball.physicsBody!.velocity
//        self.physicsWorld.gravity = noGravity
//        let slowFactor = CGFloat(0.1)
//        let slowSpeed = CGVector(dx: oldSpeed.dx * slowFactor, dy: oldSpeed.dy * slowFactor)
//        ball.physicsBody?.velocity = slowSpeed
        deathWall.isMoving = false
        let speedScaleFactor: CGFloat = 0.0
        self.scene?.physicsWorld.speed = speedScaleFactor
    }
    
    func normalSpeed(){
        self.camera?.run(SKAction.scale(to: 1.0, duration: 0.5))
//
//        self.physicsWorld.gravity = self.normalGravity
//        guard ball.physicsBody?.velocity != nil else {
//            return
//        }
//        //True if BOTH are different directions. If current velicty has flipped, then flip old speed
//        var dx = oldSpeed.dx
//        var dy = oldSpeed.dy
//        if ball.physicsBody!.velocity.dx * oldSpeed.dx < 0 {
//
//            dx = -dx
//        }
//        if ball.physicsBody!.velocity.dy * oldSpeed.dy < 0 {
//
//            dy = -dy
//        }
//        ball.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        
        deathWall.isMoving = true
        self.scene?.physicsWorld.speed = 1.0
    }
    
}
