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
    var leftScreen: SKShapeNode!
    var rightScreen: SKShapeNode!
    var pauseButton: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    override init() {
        super.init()
        self.setScale(1.0) // This is mostly for observing the state of the world as we work on things
        previousPosition = self.position
        
        leftScreen = SKShapeNode()
        rightScreen = SKShapeNode()
        pauseButton = SKSpriteNode()
        scoreLabel = SKLabelNode()
    }
    
    func initHelper(){
        // We need the camera to be added to the game scene before we can calculate the size
        // of the screen regions, so we call this helper after the camera is added to the scene
        let screenRegionXBound = self.scene!.view!.bounds.maxX
        let screenRegionYBound = self.scene!.view!.bounds.maxY
        leftScreen = SKShapeNode(rect: CGRect(x: 0, y: 0, width: (screenRegionXBound/2)-1, height: screenRegionYBound))
        leftScreen.fillColor = .clear
        leftScreen.lineWidth = 0
        leftScreen.position = CGPoint(x: -screenRegionXBound/2, y: -(screenRegionYBound/2))
        self.addChild(leftScreen)
        
        rightScreen = SKShapeNode(rect: CGRect(x: 0, y: 0, width: (screenRegionXBound/2)-1, height: screenRegionYBound))
        rightScreen.fillColor = .clear
        rightScreen.lineWidth = 1
        rightScreen.strokeColor = .purple
        rightScreen.position = CGPoint(x: 1, y: -(screenRegionYBound/2))
        self.addChild(rightScreen)
        
        let pauseTexture = SKTexture(imageNamed: "Pause")
        pauseButton = SKSpriteNode(texture: pauseTexture, color: .clear, size: CGSize(width: 30, height: 30))
        pauseButton.alpha = 0.7
//            SKShapeNode(rect: CGRect(x: 0, y: 0, width: 30, height: 30))
//        pauseButton.fillColor = .purple
//        pauseButton.lineWidth = 0
        pauseButton.position = CGPoint(x: -(screenRegionXBound/2) + 20, y: (screenRegionYBound/2) - 20)
        self.addChild(pauseButton)
        
        scoreLabel = SKLabelNode(text: " - Score")
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.bottom
        // TODO: Change y offset to +5 for release; at +20 for debug text
        scoreLabel.position = CGPoint(x: (screenRegionXBound/2), y: -(screenRegionYBound/2) + 20)
        self.addChild(scoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trackBall(ball: Player){
//        //Trying something here that should smooth out the camera motion
//        //move camera using lerp
//        //http://www.learn-to-code-london.co.uk/blog/2016/04/smoother-camera-motion-in-spritekit-using-lerp/
//        //TODO: Update constants with real values
        let currentPosition = ball.position
//
        let x = (weightedFactor(previous: previousPosition.x, current: currentPosition.x, currentWeight: 0.03) + 200)
        let y = (weightedFactor(previous: previousPosition.y, current: currentPosition.y, currentWeight: 0.03) + 75)
        previousPosition = currentPosition;
//
        self.position = CGPoint(x: x, y: y)
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
    
    func updateScore(score: CGFloat) {
        // Removes the decimal from final score
        let simpleScore: Int = Int(score)
        scoreLabel.text = "\(simpleScore) - Score"
    }
    
    func togglePauseTexture(isPaused: Bool) {
        if isPaused {
            pauseButton.texture = SKTexture(imageNamed: "Play")
        } else {
            pauseButton.texture = SKTexture(imageNamed: "Pause")
        }
    }
    
    
    
}
