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
    // TODO: Generate next segment of floor and ceiling
    
    var segmentCount = 0;
    let lengthOfSpline = 100; //Changed to smaller value for testing
    var prevFinalPoint: CGPoint?
    let arrayMaxSize: Int = 6
    var splineTracker: [SKShapeNode]?
    
    
    override init(){
        super.init()
        splineTracker = []
        addSegment()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSegment() {
        // Removes old splines from scene and memory
        // if we reach 3 splines on-screen
        if splineTracker?.count == arrayMaxSize {
            for i in 0...1 {
                splineTracker![i].removeFromParent()
                splineTracker?.remove(at: i)
            }
        }
        
        
        // firstRunDone is just to show that it is changing and making new ones
        var firstRunDone: Bool = false
        var baseCornerPoint = CGPoint(x: 0, y: 0)
        if(prevFinalPoint != nil) {
            baseCornerPoint = prevFinalPoint!
            firstRunDone = true
        }
        print("Prev:\(prevFinalPoint)")
        var floorSplinePoints = createFloorSpline(startPoint: baseCornerPoint, numberOfPoints: lengthOfSpline)
        print("THE SEGEMENT FIRST POINT \(floorSplinePoints.first!)")
        print("THE SEGEMENT last POINT \(floorSplinePoints.last!)")
        
        
        let floor = SKShapeNode(splinePoints: &floorSplinePoints, count: lengthOfSpline)
        floor.lineWidth = 5
        floor.physicsBody = SKPhysicsBody(edgeChainFrom: floor.path!)
        floor.physicsBody?.restitution = 0.25
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.friction = 1.0
        floor.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        if(firstRunDone) {
            floor.strokeColor = .red
        }
        
        
//        var ceilingSplinePoints = createCeilingSpline(startPoint: baseCornerPoint, numberOfPoints: lengthOfSpline)
        var ceilingSplinePoints = createCeilingSpline(floorPoints: floorSplinePoints)
        let ceiling = SKShapeNode(splinePoints: &ceilingSplinePoints, count: lengthOfSpline)
        ceiling.lineWidth = 5
        ceiling.physicsBody = SKPhysicsBody(edgeChainFrom: ceiling.path!)
        ceiling.physicsBody?.restitution = 0.25
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.friction = 1.0
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        if(firstRunDone) {
            ceiling.strokeColor = .red
        }
        
        
        self.addChild(ceiling)
        self.addChild(floor)
        splineTracker?.append(ceiling)
        splineTracker?.append(floor)

        
    }
    
    func createFloorSpline(startPoint:CGPoint, numberOfPoints:Int)->[CGPoint]{
        let horizMin = 40
        let horizMax = 100
        let vertMin = -2
        let vertMax = 50
        let connectDistance: CGFloat = 200 // Even looks good at 100
        
        var splinePoints = [CGPoint]()
        splinePoints.append(startPoint)
        
        let secondPoint = CGPoint(x: startPoint.x + connectDistance, y: startPoint.y)
        splinePoints.append(secondPoint)
        
        var lastPoint = secondPoint
        for i in 1 ..< numberOfPoints - 1 {
            let horizDelta = CGFloat(Int.random(in: horizMin ..< horizMax))
            let vertDelta = CGFloat(Int.random(in: vertMin ..< vertMax))
            if(i == numberOfPoints - 2) {
                lastPoint = CGPoint(x: lastPoint.x + connectDistance, y: lastPoint.y)
            } else {
                lastPoint = CGPoint(x: lastPoint.x + horizDelta, y: lastPoint.y + vertDelta)
            }
            splinePoints.append(lastPoint)
            
            //This is to compensate for the fact that the last spline point isn't drawn. It's
            //just a control point
//            if(i == numberOfPoints - 2) {
//                prevFinalPoint = lastPoint
//            }
        }
        
        prevFinalPoint = lastPoint
        print("Last point floor\(lastPoint)")
        let actualLastPoint = CGPoint(x: lastPoint.x + connectDistance, y: lastPoint.y)
        splinePoints.append(actualLastPoint)
        print("actula Last point floor\(actualLastPoint)")
        
        
        return splinePoints
    }
    
    func createCeilingSpline(floorPoints:[CGPoint])->[CGPoint]{
        let horizMin = -10 // Should be related to the min spacing above.
        let horizMax = 20
        let vertMin = 400
        let vertMax = 500
        
        var splinePoints = [CGPoint]()
        
        // Somewhere around here is where the current gap issue with the ceiling can be found...
        // floor connects great, not sure why the ceiling is having such a fit -Zach
        let firstPoint = CGPoint(x: floorPoints.first!.x,
                                 y: floorPoints.first!.y + CGFloat(vertMax))
        splinePoints.append(firstPoint)
        
        let secondPoint = CGPoint(x: floorPoints[1].x, y: firstPoint.y)
        splinePoints.append(secondPoint)
        
        var count = 2
        while count < floorPoints.count-2{
            let point = CGPoint(x: floorPoints[count].x + CGFloat(Int.random(in: horizMin ..< horizMax)),
                                y: floorPoints[count].y + CGFloat(Int.random(in: vertMin ..< vertMax)))
            splinePoints.append(point)
            count+=1
        }
        
        let lastPoint = CGPoint(x: floorPoints[floorPoints.count-2].x,
                                y: floorPoints[floorPoints.count-2].y + CGFloat(vertMax))
        splinePoints.append(lastPoint)
        print("Last point Ceil\(lastPoint)")
        
        let actualLastPoint = CGPoint(x: floorPoints[floorPoints.count-1].x, y: lastPoint.y)
        splinePoints.append(actualLastPoint)
        print("Actual Last point Ceil\(actualLastPoint)")
        
        return splinePoints
    }
    
    
    
}
