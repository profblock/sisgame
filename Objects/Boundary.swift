//
//  Boundary.swift
//  SisGame
//
//  Created by Anthoni on 2/28/19.
//  Copyright © 2019 ACCrew. All rights reserved.
//

import Foundation
import SpriteKit


class Boundary: SKShapeNode{
    // TODO:
    
    var segmentCount = 0;
    let lengthOfSpline = 500;
    
    
    override init(){
        super.init()
        addSegment()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSegment(){
        let baseCornerPoint = CGPoint(x: 0, y: 0)
        var floorSplinePoints = createFloorSpline(startPoint: baseCornerPoint, numberOfPoints: lengthOfSpline)
        let floor = SKShapeNode(splinePoints: &floorSplinePoints, count: lengthOfSpline)
        floor.lineWidth = 5
        floor.physicsBody = SKPhysicsBody(edgeChainFrom: floor.path!)
        floor.physicsBody?.restitution = 0.25
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.friction = 1.0
        
//        var ceilingSplinePoints = createCeilingSpline(startPoint: baseCornerPoint, numberOfPoints: lengthOfSpline)
        var ceilingSplinePoints = createCeilingSpline(floorPoints: floorSplinePoints)
        let ceiling = SKShapeNode(splinePoints: &ceilingSplinePoints, count: lengthOfSpline)
        ceiling.lineWidth = 5
        ceiling.physicsBody = SKPhysicsBody(edgeChainFrom: floor.path!)
        ceiling.physicsBody?.restitution = 0.25
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.friction = 1.0
        
        
        
        self.addChild(ceiling)
        self.addChild(floor)
        
        
    }
    
    func createFloorSpline(startPoint:CGPoint, numberOfPoints:Int)->[CGPoint]{
        let horizMin = 40
        let horizMax = 100
        let vertMin = -2
        let vertMax = 50
        
        var splinePoints = [CGPoint]()
        splinePoints.append(startPoint)
        
        var lastPoint = startPoint
        for _ in 0 ..< numberOfPoints {
            let horizDelta = CGFloat(Int.random(in: horizMin ..< horizMax))
            let vertDelta = CGFloat(Int.random(in: vertMin ..< vertMax))
            lastPoint = CGPoint(x: lastPoint.x + horizDelta, y: lastPoint.y + vertDelta)
            splinePoints.append(lastPoint)
        }
        
        return splinePoints
    }
    
    func createCeilingSpline(floorPoints:[CGPoint])->[CGPoint]{
        let horizMin = -10 // Should be related to the min spacing above.
        let horizMax = 20
        let vertMin = 400
        let vertMax = 500
        
        var splinePoints = [CGPoint]()
        
        let firstPoint = CGPoint(x: floorPoints.first!.x,
                                 y: floorPoints.first!.y + CGFloat(Int.random(in: vertMin ..< vertMax)))
        splinePoints.append(firstPoint)
        
        var count = 1
        while count < floorPoints.count-1{
            let point = CGPoint(x: floorPoints[count].x + CGFloat(Int.random(in: horizMin ..< horizMax)),
                                y: floorPoints[count].y + CGFloat(Int.random(in: vertMin ..< vertMax)))
            splinePoints.append(point)
            count+=1
        }
        
        let lastPoint = CGPoint(x: floorPoints.last!.x,
                                y: floorPoints.last!.y + CGFloat(Int.random(in: vertMin ..< vertMax)))
        splinePoints.append(lastPoint)
        
        return splinePoints
    }
    
    
    
}
