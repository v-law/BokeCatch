//
//  GameScene.swift
//  BokeCatch
//
//  Created by Vernita Lawren on 11/10/21.
//

import SpriteKit
import AVFAudio

class GameScene: SKScene {
    
    var manager: GameManager?
    
    var level = 0

    private var pokemon: SKSpriteNode!
    private var pokeball: SKSpriteNode!
    
    private var didCutRope = false
    private var isCaught = false
    var startBtn = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        
        makeStartBtn()
        setUpPhysics()
        setUpScenery()
        
        setUpPokeball()
        setUpRopes()
        setUpPokemon()
        
    }
    
    private static var backgroundMusic: AVAudioPlayer!
    
    //MARK: - Level setup
    
    private func setUpPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
    }
    
    private func setUpScenery() {
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = CGFloat(0)
        addChild(background)
    }
    
    private func setUpMusic() {
//        if GameScene.backgroundMusic == nil {
//          let backgroundMusic = Bundle.main.url(
//            forResource: "nature",
//            withExtension: nil)
//          
//          do {
//            let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
//            GameScene.backgroundMusic = theme
//          } catch {
//            // couldn't load file :[
//          }
//          
//          GameScene.backgroundMusicPlayer.numberOfLoops = 1
//        }

    }
    
    
    private func setUpPokeball() {
        pokeball = SKSpriteNode(imageNamed: "pokeball")
        pokeball.size = CGSize(width: 50, height: 50)
        pokeball.position = CGPoint(x: 0, y: 125)
        pokeball.zPosition = CGFloat(3)
        pokeball.physicsBody = SKPhysicsBody(circleOfRadius: pokeball.size.height / 2)
        pokeball.physicsBody?.categoryBitMask = UInt32(8)
        
        pokeball.physicsBody?.collisionBitMask = 0
        pokeball.physicsBody?.density = 0.5

        addChild(pokeball)
    }
    
   
    func makeStartBtn() {
        startBtn = SKSpriteNode(imageNamed: "start")
        startBtn.position = CGPoint(x: 0, y: -30)
        startBtn.zPosition = CGFloat(2)
        startBtn.setScale(0)
        let initialState = SKAction.scale(to: 0.1, duration: 0.7)
        let afterState = SKAction.scale(to: 0.15, duration: 0.7)
        let sequence = SKAction.sequence([initialState,afterState,initialState,afterState])
        
//        startBtn.run(SKAction.scale(to: 0.1, duration: 0.7))
        startBtn.run(.repeatForever(sequence))
        self.addChild(startBtn)
    }
    
    //MARK: - Rope methods
    
    private func setUpRopes() {
        // load rope data
        let decoder = PropertyListDecoder()
        guard
          let dataFile = Bundle.main.url(
            forResource: "RopeData.plist",
            withExtension: nil),
          let data = try? Data(contentsOf: dataFile),
          let levels = try? decoder.decode([[RopeData]].self, from: data)
        else {
          return
        }
        
        let ropes = levels[level]
        
        //add ropes
        for (i, ropeData) in ropes.enumerated() {
            let anchorPoint = CGPoint(
                x: ropeData.relAnchorPoint.x * size.width,
                y: ropeData.relAnchorPoint.y * size.height)
            let rope = RopeNode(length: ropeData.length, anchorPoint: anchorPoint, name: "\(i)")
            rope.zPosition = CGFloat(1)
            
            //add to scene
            rope.addToScene(self)
            
            //connect end of rope to pokeball
            rope.attachToPokeball(pokeball)
        }
    }
    
    //MARK: - Pokemon methods
    
    private func setUpPokemon() {
        pokemon = SKSpriteNode(imageNamed: "pokemon")
        pokemon.size = CGSize(width: 90, height: 87.3)
        pokemon.position = CGPoint(x: 0, y: -150)
        pokemon.zPosition = CGFloat(2)
        pokemon.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "pokemon"), size: pokemon.size)
        pokemon.physicsBody?.categoryBitMask = UInt32(1)
        pokemon.physicsBody?.collisionBitMask = 0
        pokemon.physicsBody?.contactTestBitMask = UInt32(8)
        pokemon.physicsBody?.isDynamic = false
            
        addChild(pokemon)

    }
    
    private func runCatchAnimation(withDelay dellay: TimeInterval) {
        //to-do: add light emanating from pokeball position and end level pop up words "you caught <string pokemon name>!"
        
    }
    
    //MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didCutRope = false
        startBtn.removeFromParent()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
          let startPoint = touch.location(in: self)
          let endPoint = touch.previousLocation(in: self)
          
          // check if rope cut
          scene?.physicsWorld.enumerateBodies(
            alongRayStart: startPoint,
            end: endPoint,
            using: { body, _, _, _ in
              self.checkRopeCut(withBody: body)
          })
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let shrink = SKAction.scale(to: 0, duration: 0.08)
        let removeNode = SKAction.removeFromParent()
        let sequence = SKAction.sequence([shrink, removeNode])
        pokemon.run(sequence)
        self.manager?.gameEnded(won: false)
        self.removeFromParent()
    }
    //MARK: - Game logic
    
    private func checkRopeCut(withBody body: SKPhysicsBody) {
        if didCutRope {
            return
        }
        
        let node = body.node!
        
        // if it has a name it must be a rope node
        if let name = node.name {
            // snip the rope
            node.removeFromParent()
            
            // fade out all nodes matching name
            enumerateChildNodes(withName: name, using: { node, _ in
                let fadeAway = SKAction.fadeOut(withDuration: 0.25)
                let removeNode = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fadeAway, removeNode])
                node.run(sequence)
            })
        
            pokemon.removeAllActions()
            pokemon.texture = SKTexture(imageNamed: "pokemon")
            didCutRope = true
        }
    }
    
    private func switchToNewGame(withTransition transition: SKTransition) {
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run {
            let scene = GameScene(size: self.size)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.view?.presentScene(scene, transition: transition)
        }

        run(.sequence([delay, sceneChange]))
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    override func update(_ currentTime: TimeInterval) {
        if isCaught {
          return
        }
        
        if pokeball.position.y <= CGFloat(-100){
          isCaught = true
          self.manager?.gameEnded(won: false)
            self.removeFromParent()
        }
    }
    
    
}

