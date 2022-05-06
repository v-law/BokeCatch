//
//  RopeNode.swift
//  PokéCatch iOS
//
//

import UIKit
import SpriteKit

class RopeNode: SKNode {
    
    private let length: Int
    private let anchorPoint: CGPoint
    private var ropeSegments: [SKNode] = []
    
    init(length: Int, anchorPoint: CGPoint, name: String) {
      self.length = length
      self.anchorPoint = anchorPoint

      super.init()

      self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
      length = aDecoder.decodeInteger(forKey: "length")
      anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")

      super.init(coder: aDecoder)
    }
    
    func addToScene(_ scene: SKScene) {
      // add rope to scene
      zPosition = CGFloat(2)
      scene.addChild(self)
      
      // create rope holder
      let ropeHolder = SKSpriteNode(imageNamed: "ropeHolder")
        ropeHolder.size = CGSize(width: 2.5, height: 2.5)
      ropeHolder.position = anchorPoint
      ropeHolder.zPosition = 1
        ropeHolder.setScale(10)
          
      addChild(ropeHolder)
          
      ropeHolder.physicsBody = SKPhysicsBody(circleOfRadius: ropeHolder.size.width / 2)
      ropeHolder.physicsBody?.isDynamic = false
      ropeHolder.physicsBody?.categoryBitMask = UInt32(2)
      ropeHolder.physicsBody?.collisionBitMask = 0
      
      // add each of the rope parts
      for i in 0..<length {
        let ropeSegment = SKSpriteNode(imageNamed: "ropeTexture")
        let offset = ropeSegment.size.height * CGFloat(i + 1)
        ropeSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
        ropeSegment.name = name
        
        ropeSegments.append(ropeSegment)
        addChild(ropeSegment)
        
        ropeSegment.physicsBody = SKPhysicsBody(rectangleOf: ropeSegment.size)
        ropeSegment.physicsBody?.categoryBitMask = UInt32(4)
        ropeSegment.physicsBody?.collisionBitMask = UInt32(2)
      }
      
      // set up joint for rope holder
      let joint = SKPhysicsJointPin.joint(
        withBodyA: ropeHolder.physicsBody!,
        bodyB: ropeSegments[0].physicsBody!,
        anchor: CGPoint(
          x: ropeHolder.frame.midX,
          y: ropeHolder.frame.midY))

      scene.physicsWorld.add(joint)

      // set up joints between rope parts
      for i in 1..<length {
        let nodeA = ropeSegments[i - 1]
        let nodeB = ropeSegments[i]
        let joint = SKPhysicsJointPin.joint(
          withBodyA: nodeA.physicsBody!,
          bodyB: nodeB.physicsBody!,
          anchor: CGPoint(
            x: nodeA.frame.midX,
            y: nodeA.frame.minY))
        
        scene.physicsWorld.add(joint)
      }
    }
    
    func attachToPokeball(_ pokeball: SKSpriteNode) {
      // align last segment of rope with pokeball
      let lastNode = ropeSegments.last!
      lastNode.position = CGPoint(x: pokeball.position.x,
                                  y: pokeball.position.y + pokeball.size.height * 0.1)
          
      // set up connecting joint
      let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                                          bodyB: pokeball.physicsBody!,
                                          anchor: lastNode.position)
          
      pokeball.scene?.physicsWorld.add(joint)
    }
    
}
