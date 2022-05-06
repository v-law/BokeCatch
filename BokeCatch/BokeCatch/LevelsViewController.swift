//
//  LevelsViewController.swift
//  BokeCatch
//
//  Created by Ryan Cocuzzo on 11/11/21.
//

import UIKit

class LevelsViewController: UIViewController {
    
    var LEVEL = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToLevelOne(_ sender: Any) {
        LEVEL = 0
        toGame()
    }
    
    @IBAction func goToLevelTwo(_ sender: Any) {
        LEVEL = 1
        toGame()
    }
    
    @IBAction func goToLevelThree(_ sender: Any) {
        LEVEL = 2
        toGame()
    }
    
    func toGame() {
        let vc = self.storyboard?.instantiateViewController(identifier: "GameViewController") as! GameViewController
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameViewController {
            vc.LEVEL = LEVEL
        }
    }
    

}
