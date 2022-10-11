//
//  GameOverScene.swift
//  Mazeman
//
//  Created by Spencer Kinsey-Korzym on 4/16/22.
//

import Foundation

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    var highscores: [Int]!
    override func didMove(to view: SKView) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view?.addGestureRecognizer(tapGR)
        
    }
    

    init(size: CGSize, score: Int, hs: [Int]){
        
        super.init(size: size)
         
        let currentScoreLabel = SKLabelNode(text: "Current Score: \(score)")
        let highscoreLabel = SKLabelNode(text: "Highscores: ")
    
        currentScoreLabel.fontSize = 60
         highscores = hs
      
         for i in 0...2{
             highscoreLabel.text = highscoreLabel.text! + String(highscores[i])
             if i != 2{
                 highscoreLabel.text = highscoreLabel.text! + ", "
             }
         }
        let newGameLabel = SKLabelNode(text: "Click the screen to begin a new game!")
        currentScoreLabel.position = CGPoint(x: size.width/2, y: size.height - 128)
         highscoreLabel.position.x = currentScoreLabel.position.x
         highscoreLabel.position.y = currentScoreLabel.position.y - 64
        newGameLabel.position.x = highscoreLabel.position.x
        newGameLabel.position.y = highscoreLabel.position.y - 64
        self.addChild(currentScoreLabel)
         self.addChild(highscoreLabel)
        self.addChild(newGameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tap(recognizer: UIGestureRecognizer){
        let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        
      
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
            
        self.view?.presentScene(newScene, transition: flipTransition)
    }
    

}
