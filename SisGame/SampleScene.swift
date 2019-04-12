//
//  SampleScene.swift
//  SampleSpriteKit
//
//  Created by Aaron Block on 2/4/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit

//4. Add new array of contaacbles with new segment
//5. remove old array of contacables with old segment.

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
    var staminaLoss : CGFloat = 0.0
    private var score: CGFloat?
    let scoreScalingFactor: CGFloat = 0.01
    private var ground: Boundary?
    private let normalGravity = CGVector(dx: 0, dy: -9.8)
    private let noGravity = CGVector(dx: 0, dy: 0)
    private var oldSpeed = CGVector.zero
    


    private var par1:ParallaxBackground?
    private var par2:ParallaxBackground?
    
    // Time of last frame
    private var lastFrameTime : TimeInterval = 0
    
    // Time since last frame
    private var deltaTime : TimeInterval = 0
    
    //Change to false enable death wall
    let debug : Bool = true
    
    var currentContactables = [Contactable]()
    
    
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
        
        // TODO: Move to array
        let coin = CoinBrick(position:CGPoint(x: ball.position.x+200, y: ball.position.y+200), isCoin: true)
        let brick = CoinBrick(position:CGPoint(x: ball.position.x+200, y: ball.position.y-200),isCoin: false)
        
        
        let path = CGMutablePath()
        
        let enemyStartPoint = CGPoint(x: ball.position.x+100, y: ball.position.y+100)
        path.move(to: CGPoint(x:0,y:0))
        let enemyEndPoint = CGPoint(x: ball.position.x+300, y: ball.position.y+100)
        path.addLine(to: CGPoint(x:100,y:100))
        let enemy = Enemy(typeOfEnemy: Enemy.TypeOfEnemy.basic,position:enemyStartPoint, path: path )
        currentContactables.append(coin)
        currentContactables.append(brick)
        currentContactables.append(enemy)

        for contacable in currentContactables {
            self.addChild(contacable)
        }
        
        myCamera = Camera()
        self.camera = myCamera
        self.addChild(myCamera)
        myCamera.initHelper()
        myCamera.addChild(staminaBar)
        staminaBar.initHelper()
        launcher = Launcher(mainNode: myCamera)
        
    }
    
    func generateSegment(){
        guard let ground = ground else {
            return
        }
        let (floorSplinePoints, ceilingSplinePoints) = ground.addSegment()
        
        var skip = Int.random(in: 1...10)
        
        for index in 0..<floorSplinePoints.count {
            let floorPoint = floorSplinePoints[index]
            let ceiliningPoint = ceilingSplinePoints[index]
            if skip <= 0 {
                let yBufferDistance = CGFloat(25)
                let randomY = CGFloat.random(in: (floorPoint.y + yBufferDistance)  ..< (ceiliningPoint.y - yBufferDistance))
                let xRange = CGFloat(10.0)
                let randomX  = CGFloat.random(in: (floorPoint.x - xRange) ..< (floorPoint.x + xRange) )
                let contactablePoint = CGPoint(x: randomX, y: randomY)
                let contacable = CoinBrick(position: contactablePoint, isCoin: Bool.random())
                currentContactables.append(contacable)
                self.addChild(contacable)
                skip = Int.random(in: 1...10)
            } else {
                skip -= 1
            }
        }

    }
    
    override func didFinishUpdate() {
        self.deathWall!.moveWall(currentPositionOfPlayer: ball.position)
        // Updating score label in UI
        self.myCamera.updateScore(score: score!)
        par1?.updateCamera(camera: self.myCamera)
        
        // TODO: Change from 300 to double of the width of the screen
        if(ball.position.x >= ground!.prevFinalPoint!.x - (self.view!.bounds.maxX * 2.0)) {
             generateSegment()
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
                    staminaLoss = 0.0
                    staminaBar.startProjection()
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
                for contacable in currentContactables {
                    contacable.toggle()
                }
            }
            

        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let startPoint = self.startPoint{
            if(myCamera.leftScreen.contains(self.startPoint!) && isLauncherOnScreen == true){
                launcher?.repaint(curTap: touch.location(in: self.myCamera), stamina: ball.stamina)
                let endPoint = touch.location(in: self.myCamera)
                staminaLoss = Player.projectedStamina(startPoint: startPoint, endPoint: endPoint)
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
                    staminaBar.endProjection()
                    launcher?.destroy()
                    staminaLoss = 0.0
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
            let repaintOutcome = launcher!.repaint(stamina: ball.stamina)
            // If we couldn't repaint, it's because the mainCircle is too small
            // and the player has run out of stamina
            if(!repaintOutcome) {
                // If we've run out of stamina, we destroy the launcher,
                // reset staminaLoss and the game's speed, ensure the player's stamina is empty
                // and end the projection of the stamina bar
                launcher?.destroy()
                isLauncherOnScreen = false
                normalSpeed()
                staminaLoss = 0.0
                ball.stamina = 0.0
                staminaBar.endProjection()
            }
        }
        staminaBar.changeStamina(newStamina: ball.stamina-staminaLoss)
        
        // If we don't have a last frame time value, this is the first frame,
        // so delta time will be zero.
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime
        
        // Moving the parallax background with a scaling factor based on player's velocity
        par1?.move(scene: self, speed: (ball.physicsBody!.velocity.dx * 0.0001), deltaTime: deltaTime)

        
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
