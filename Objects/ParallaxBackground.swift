//
//  ParallaxObject.swift
//  SampleSpriteKit
//
//  Created by Zachary Aamold on 2/22/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class ParallaxBackground {
    
    public var sprite:SKVideoNode? // Switch to SKVideoNode
    public var spriteNext:SKVideoNode?
    private var offset:CGFloat?
    private var offsetNext:CGFloat?
    
    private var effectNode:SKEffectNode!
    
    private var player: AVQueuePlayer!
    private var playerLooper: AVPlayerLooper!
    private var playerItem: AVPlayerItem!
    
    init(spriteName: String, gameScene: SKScene, heightOffset: CGFloat, zPosition: CGFloat) {

        // Initialization of video player gently borrowed from here: https://github.com/quentinfasquel/playgrounds/blob/master/TransparentVideo.playground/Pages/page-1.xcplaygroundpage/Contents.swift
        guard let url = Bundle.main.url(forResource: spriteName, withExtension: "mov") else {
            print("Can't find example video")
            return
        }

        offset = 0.0
        offsetNext = 0.0
        // Creating our player
        playerItem = AVPlayerItem(url: url)
        player = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

        // Getting the size of our video
        let videoTrack = playerItem.asset.tracks(withMediaType: .video).first!
        let videoSize = videoTrack.naturalSize

        // Adding a `SKVideoNode` to display video in our scene
        sprite = SKVideoNode(avPlayer: player)
        sprite?.zPosition = zPosition
        sprite?.position = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2 + heightOffset)

        sprite?.size = videoSize.applying(CGAffineTransform(scaleX: 1.0, y: 0.5)) // Change y from 0.5
        
        spriteNext = SKVideoNode(avPlayer: player)
        spriteNext?.position = CGPoint(x: CGFloat((sprite?.position.x)!) + (sprite?.size.width)!, y: (sprite?.position.y)!)
        spriteNext?.zPosition = zPosition
        spriteNext?.size = videoSize.applying(CGAffineTransform(scaleX: 1.0, y: 0.5)) // Change y from 0.5

        // Let's make it transparent, using an SKEffectNode,
        // since a shader cannot be applied to a SKVideoNode directly
        effectNode = SKEffectNode()
        // Loving Swift's multiline syntax here:
        effectNode.shader = SKShader(source: """
void main() {
  vec2 texCoords = v_tex_coord;
  vec2 colorCoords = vec2(texCoords.x, (1.0 + texCoords.y) * 0.5);
  vec2 alphaCoords = vec2(texCoords.x, texCoords.y * 0.5);
  vec4 color = texture2D(u_texture, colorCoords);
  float alpha = texture2D(u_texture, alphaCoords).r;
  gl_FragColor = vec4(color.rgb, alpha);
}
""")
        gameScene.addChild(effectNode)
        effectNode.addChild(spriteNext!)

        effectNode.addChild(sprite!)

        // Start playing your video
//        player.play()
        player.play()
        
        // Doesn't work, also causes lag spike in-game
        // Pulled from: https://stackoverflow.com/questions/39258312/how-to-loop-video-with-avplayerlooper
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
////            if(!self.isStopped){
//            print("Restarting video")
//            self.player.pause()
//            self.player.seek(to: CMTime.zero)
//            self.player.play()
//
////            }
//        }
        
        
//        let stringPath = Bundle.main.path(forResource: spriteName, ofType: "mov")
//        let path = URL(fileURLWithPath:stringPath!)
//        self.sprite = SKVideoNode(url: path)
////        self.spriteNext = spriteNext
//        sprite?.position = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2 + heightOffset)
//

//
//        sprite?.play()
//        spriteNext?.play()
    }
    
    func updateCamera(camera: SKCameraNode) {
        effectNode.position.x = camera.position.x + offset!
        effectNode.position.y = camera.position.y
//        sprite?.position.x = camera.position.x + offset!
//        sprite?.position.y = camera.position.y
//        spriteNext?.position.x = camera.position.x + offsetNext!
//        spriteNext?.position.y = camera.position.y
    }
    
    // Move a pair of sprites leftward based on a speed value;
    // when either of the sprites goes off-screen, move it to the
    // right so that it appears to be seamless movement
    // Pulled from: http://radar.oreilly.com/2015/08/parallax-scrolling-for-ios-with-swift-and-sprite-kit.html
    func move(scene: SKScene, speed : CGFloat, deltaTime: TimeInterval) {
        var newPosition = CGPoint.zero

        // For both the sprite and its duplicate:
        for spriteToMove in [self.sprite, self.spriteNext] {

            // Shift the sprite leftward based on the speed
            newPosition = (spriteToMove?.position)!
            newPosition.x -= CGFloat(speed * CGFloat(deltaTime))
            spriteToMove?.position = newPosition
            
            if(spriteToMove == self.sprite) {
                offset! -= CGFloat(speed * CGFloat(deltaTime))
            } else {
                offsetNext! -= CGFloat(speed * CGFloat(deltaTime))
            }

            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if (spriteToMove?.frame.maxX)! < scene.frame.minX {

                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                spriteToMove!.position =
                    CGPoint(x: spriteToMove!.position.x +
                        spriteToMove!.size.width * 2,
                            y: spriteToMove!.position.y)
                
                if(spriteToMove == self.sprite) {
                    offset = 0
                } else {
                    offsetNext = 0
                }
                
            }

        }
    }

}
