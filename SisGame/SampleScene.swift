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
    static let GravityWell: UInt32 = 0b10000000      // 128
}

//SKScenes are the "view" equivalant for sprite kit.
class SampleScene: SKScene, SKPhysicsContactDelegate {
    
    private var mainNode:SKNode?

    
    var ball : Player!
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
    


//    private var par1:ParallaxBackground?
//    private var par2:ParallaxBackground?
    
    // Time of last frame
    private var lastFrameTime : TimeInterval = 0
    
    // Time since last frame
    private var deltaTime : TimeInterval = 0
    
    //Change to false enable death wall
    let debug : Bool = true
    
    var currentContactables = [[Contactable]]()
    
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        score = 0
        ball = Player()
        staminaBar = StaminaBar(stamina: ball.stamina)
        
//        par1 = ParallaxBackground(spriteName: "Parallax-Diamonds-1", gameScene: self, heightOffset: 0, zPosition: -1)
//        par2 = ParallaxBackground(spriteName: "Parallax-Diamonds-2", gameScene: self, heightOffset: 0, zPosition: -2)
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
        
        // Initialization of base contactables
        let coin = CoinBrick(position:CGPoint(x: ball.position.x+200, y: ball.position.y+200), isCoin: true)
        
        let gravityWell = GravityWell(position: CGPoint(x: ball.position.x+200, y: ball.position.y-200), isOn: true)
        
        let enemyStartPoint = CGPoint(x: ball.position.x+100, y: ball.position.y+100)
        
        let enemy = Enemy(typeOfEnemy: Enemy.TypeOfEnemy.basic,position:enemyStartPoint, isOn: true)
        // A temporary array to store our default contactables
        let tempContactables : [Contactable] = [coin, gravityWell, enemy]
        // Adding our temporary array to our list of all contactables
        currentContactables.append(tempContactables)

        // Adding all default contactables to the scene
        for contactable in currentContactables[0] {
            self.addChild(contactable)
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
        // Making sure the ground exists first
        guard let ground = ground else {
            return
        }
        // Retrieving new floor and ceiling splines for reference
        let (floorSplinePoints, ceilingSplinePoints) = ground.addSegment()
        
        // Skip helps us randomly determine where to add contactables
        var skip = Int.random(in: 1...10)
        
        // Initializing an array for new contactables in this area
        var tempConctactables = [Contactable]()
        
        for index in 0..<floorSplinePoints.count {
            // Creating helper variables for current points on floor and ceiling
            let floorPoint = floorSplinePoints[index]
            let ceilingPoint = ceilingSplinePoints[index]
            // If skip has reached 0, we add a contactable at this location
            if skip <= 0 {
                // Setting variables to help us determine random distances between floor and ceiling points,
                // making some random noise in the x-axis, and a percentage to determine which contactable to make
                let yBufferDistance = CGFloat(25)
                let randomY = CGFloat.random(in: (floorPoint.y + yBufferDistance)  ..< (ceilingPoint.y - yBufferDistance))
                let xRange = CGFloat(10.0)
                let randomX  = CGFloat.random(in: (floorPoint.x - xRange) ..< (floorPoint.x + xRange) )
                let contactablePoint = CGPoint(x: randomX, y: randomY)
                let percentage = Int.random(in: 0 ... 100)
                // Will hold the new contactable momentarily
                let contactable : Contactable
                if percentage <= 16 {
                    // 16% chance of making a coin
                    contactable = CoinBrick(position: contactablePoint, isCoin: true)
                } else if percentage > 16 && percentage <= 32 {
                    // 16% chance of making a brick
                    contactable = CoinBrick(position: contactablePoint, isCoin: false)
                } else if percentage > 32 && percentage <= 48 {
                    // 16% chance of making an Enemy who starts on
                    contactable = Enemy(typeOfEnemy: .basic, position: contactablePoint, isOn: true)
                } else if percentage > 48 && percentage <= 65 {
                    // 17% chance of making an Enemy who starts off
                    contactable = Enemy(typeOfEnemy: .basic, position: contactablePoint, isOn: false)
                } else if percentage > 65 && percentage <= 82 {
                    // 17% chance of making a Gravity Well that starts on
                    contactable = GravityWell(position: contactablePoint, isOn: true)
                } else {
                    // 18% chance of making a Gravity Well that starts off
                    contactable = GravityWell(position: contactablePoint, isOn: false)
                }
                // Adds the new contactable to our list of contactables for this area
                tempConctactables.append(contactable)
                // Adds the new contactable to the scene itself
                self.addChild(contactable)
                // Reinitializes our random number for the next contactable
                skip = Int.random(in: 1...10)
            } else {
                // If skip is not yet at 0, we subtract 1 to get closer to a new contactable
                skip -= 1
            }
        }
        
        // Adds all new contactables to our list of all contactables
        currentContactables.append(tempConctactables)
        // If the list has reached its max size (3 lists)...
        if currentContactables.count > 3 {
            // ...removes all contactables of the oldest group from the scene
            // and removes the list from memory as well
            for contactable in currentContactables[0] {
                contactable.removeFromParent()
            }
            currentContactables.remove(at: 0)
        }

    }
    
    override func didFinishUpdate() {
        self.deathWall!.moveWall(currentPositionOfPlayer: ball.position)
        // Updating score label in UI
        self.myCamera.updateScore(score: score!)
//        par1?.updateCamera(camera: self.myCamera)
        
        // Creates new segments and contactables whenever the player reaches the end of current spline
//        if(ball.position.x >= ground!.prevFinalPoint!.x - (self.view!.bounds.maxX * 2.0)) {
//             generateSegment()
//        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            
            startPoint = touch.location(in: self.myCamera)

            // If they've pressed the pause button, toggle pause
            if(myCamera.pauseButton.contains(touch.location(in: self.myCamera))){

                isPaused.toggle()
                return
                // Pressing the left side of the screen is for launching
            } else if(myCamera.leftScreen.contains(touch.location(in: self.myCamera))){
                // Only allow launching if we have stamina
                if ball.stamina > 0.0 {
                    lightPause()
                    staminaLoss = 0.0
                    staminaBar.startProjection()
                    launcher?.create(tap: touch.location(in: self.myCamera), stamina: ball.stamina)
                    isLauncherOnScreen = true;
                }
                return
                // Pressing the right side of the screen activates toggle
            } else if(myCamera.rightScreen.contains(touch.location(in: self.myCamera))){
                // Toggle color of right screen for verification of touch
                objectsAreActivated.toggle()
                if objectsAreActivated {
                    myCamera.rightScreen.strokeColor = .purple
                } else {
                    myCamera.rightScreen.strokeColor = .blue
                }
                
                // Going through all contactables on screen and
                // toggling them from their current state to their alternate one
                for contactableList in currentContactables {
                    // Requires two for loops because currentContactables is two-dimensional
                    for contactable in contactableList {
                        contactable.toggle()
                    }
                }
                
                return
            }
            

        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Removed this logic because launcher being on screen is enough to know
        // if we need to repaint and continue the launch
        // myCamera.leftScreen.contains(self.startPoint!) &&
        
        if let touch = touches.first, let startPoint = self.startPoint{
            // If the launcher is on the screen...
            if isLauncherOnScreen {
                // ...then we update the launcher to current stamina and finger location
                launcher?.repaint(curTap: touch.location(in: self.myCamera), stamina: ball.stamina)
                let endPoint = touch.location(in: self.myCamera)
                // updating stamina loss based on current velocity calculations
                staminaLoss = Player.projectedStamina(startPoint: startPoint, endPoint: endPoint)
                // If we've run out of stamina, stops the launch from happening entirely and restores game speed
                if(ball.stamina <= 0.0) {
                    ball.stamina = 0
                    launcher?.destroy()
                    isLauncherOnScreen = false
                    normalSpeed()
                }
                
                
            }
            
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Removed this logic from if; this was causing the launcher to remain
        // on screen even if the player ended the launch in the right side of the screen.
        // Leaving here for further discussion, but seems extraneous
        // myCamera.leftScreen.contains(touch.location(in: self.myCamera))){
        // if(myCamera.leftScreen.contains(self.startPoint!) &&
        
        if let touch = touches.first, let startPoint = self.startPoint{
            // If the launcher is on screen...
            if(isLauncherOnScreen){
                // ...then we end the launch, resetting game speed,
                // restoring/removing UI components for launching, and
                // resetting staminaLoss
                normalSpeed()
                staminaBar.endProjection()
                launcher?.destroy()
                staminaLoss = 0.0
                isLauncherOnScreen = false;
                
                let endPoint = touch.location(in: self.myCamera)
                // Performs the launching impulse upon the ball's physicsBody
                ball.launchBall(startPoint: startPoint, endPoint: endPoint)

            }
            
        }
        
    }
    
    override func didSimulatePhysics() {
        // Keeping the camera focused on the ball
        myCamera.trackBall(ball: ball)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let staminaDecreaseRate : CGFloat = 0.5
        let staminaIncreaseRate : CGFloat = 0.5
        // If the launcher is not on screen...
        if (isLauncherOnScreen == false){
            // ...then the ball is just rolling, so we
            // increase stamina, as long as it's not full
            if(ball.stamina < ball.maxStamina){
                ball.stamina += staminaIncreaseRate
            }
        } else {
            // ...otherwise, we decrease stamina and update the launcher
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
        // staminaBar constantly updates to show both current and projected stamina loss
        staminaBar.changeStamina(newStamina: ball.stamina-staminaLoss)
        
        // If we don't have a last frame time value, this is the first frame,
        // so delta time will be zero.
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime
        
        // Moving the parallax background with a scaling factor based on player's velocity
//        par1?.move(scene: self, speed: (ball.physicsBody!.velocity.dx * 0.0001), deltaTime: deltaTime)

        
        // Updating score value, based on distance travelled and scaling factor
        score = CGFloat(ball.calculateDistanceTravelled() * scoreScalingFactor).rounded()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // The two bodies involved in the collision
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // We make sure that the smaller bit mask comes first always, for ease of use
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // If the ball comes in contact with a coin...
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Coin != 0)) {
//            print("The ball came into contact with a coin")
            // ...we verify that it's the player and a coin, increase stamina, and remove the coin
            if let player = firstBody.node as? Player, let
                coin = secondBody.node as? CoinBrick {
                // Adds a fourth of total stamina to current stamina, or just puts us at max, whichever is less
                player.stamina = CGFloat.minimum(player.maxStamina, player.stamina + (player.maxStamina/4))
                coin.removeFromParent()
                return // No need for more collision checks if we accomplished our goal
            }
        }
        
        // If the ball comes in contact with a brick...
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Brick != 0)) {
            // ...the ball bounces off; no further logic yet
//            print("The ball came into contact with a brick")
        }

        
        // If the ball comes in contact with a Gravity Well...
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.GravityWell != 0)) {
            // ...the ball bounces off; no further logic yet

        }
        
        // If the ball comes in contact with an enemy...
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Enemy != 0)) {
            print("The ball came into contact with an Enemy")
            // ...we verify that it is the player, then decrease their stamina
            if let player = firstBody.node as? Player, let
                _ = secondBody.node as? Contactable {
                // Subtracts a fourth of total stamina to current stamina, or just puts us at 0, whichever is greater
                player.stamina = CGFloat.maximum(0.0, player.stamina - (player.maxStamina/4))
                return
            }
        }
        
        // If the ball comes in contact with the deathWall...
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Wall != 0)) {
            // ...achieves a game over state (as long as we're not debugging)
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
