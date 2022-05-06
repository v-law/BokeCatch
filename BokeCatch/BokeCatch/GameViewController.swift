//
//  GameViewController.swift
//  BokeCatch
//
//  Created by Vernita Lawren on 11/10/21.
//

import UIKit
import SpriteKit
import GameplayKit

protocol GameManager {
    func gameEnded(won: Bool)
}
class GameViewController: UIViewController, GameManager {
    
    var LEVEL = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScene()
    }
    
    func loadScene() {
        let scene = GameScene()
        scene.manager = self
        scene.level = LEVEL
            
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
                
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
                
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
                    
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func gameEnded(won: Bool) {
        confirmLeave()
    }
    
    func confirmLeave() {
        // Create the action buttons for the alert.
           let stayAction = UIAlertAction(title: "Yes",
                                style: .cancel) { (action) in
            self.loadScene()
           }
           let returnAction = UIAlertAction(title: "Main Lobby",
                                style: .default) { (action) in
                let vc = self.storyboard?.instantiateViewController(identifier: "LevelsViewController") as! LevelsViewController
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
           }
           
           // Create and configure the alert controller.
           let alert = UIAlertController(title: "Game Over!",
                 message: "Play again?",
                 preferredStyle: .alert)
           alert.addAction(stayAction)
           alert.addAction(returnAction)
                
        self.present(alert, animated: true) {
              // The alert was presented
           }
    }
    

}
