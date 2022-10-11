//
//  GameOverScene.swift
//  SpriteKitGame
//
//  Created by Eyuphan Bulut on 3/31/22.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    var button: UIButton!
    
    override func didMove(to view: SKView) {
        
        button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = UIColor.blue
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel!.text = "Button"
        
        
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        self.view?.addSubview(button)
         
        
        
    }
    
    @objc func buttonClicked(){
        
        print("Hello")
    }
    
    init(size: CGSize, won: Bool){
        
        
        
        super.init(size: size)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = (won ? "You Win!" : "You Lose")
        gameOverLabel.fontSize = 60
        
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(gameOverLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch  = touches.first
        
        //let loc = touch?.location(in: self.view)
        
        //print(loc)
       
            // transition back to first scene
            
        //let flipTransition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        
        let fd = SKTransition.fade(with: .red, duration: 1)
        
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
            
        self.view?.presentScene(newScene, transition: fd)
        
        button.removeFromSuperview()
        
        
    }
    

}
