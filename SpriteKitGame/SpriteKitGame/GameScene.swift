//
//  GameScene.swift
//  SpriteKitGame
//
//  Created by Eyuphan Bulut on 3/24/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var label: SKLabelNode!
    var circle: SKShapeNode!
    var ball: SKSpriteNode!
    var ground: SKNode!
    var bird: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate =  self
        
        self.backgroundColor = .white
        
       label = SKLabelNode(text: "First SpriteKit Game")
        label.position = CGPoint(x: 200, y: 200)
        
        label.fontSize = 40
        label.fontColor = .red
        addChild(label)
        
        circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = .green
        
        circle.position = CGPoint(x: 300, y: 500)
        //addChild(circle)
        
        
        ball = SKSpriteNode(imageNamed: "tennisBall")
        
        ball.setScale(0.05)
        
        ball.position = CGPoint(x: 250, y: 650)
        
        addChild(ball)
        addChild(circle)
        
        circle.zPosition = 1
        
        
        ground = SKNode()
        ground.position = CGPoint(x: self.size.width/2, y: 20)
        addChild(ground)
        
        
        addPhysics()
        
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeGR.direction = [.right]
        self.view?.addGestureRecognizer(swipeGR)
        
        addBitMasks()
        
        //addFlappyBird()
        
        //addMusic()
        
        addPlane()
        
    }
    
    
    func addPlane(){ // and propeller
        
        let sprite = SKSpriteNode(imageNamed:"PLANE 8 N")
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        // position is center of image
        sprite.position =  CGPoint(x:self.frame.width/2, y:(sprite.frame.height/2))
        self.addChild(sprite)
        
        let propeller = SKSpriteNode(imageNamed: "PLANE PROPELLER 1")
       
        propeller.setScale(0.5)
        //propeller.position = CGPoint(x: sprite.position.x, y: sprite.size.height)
        propeller.position = CGPoint(x: 0, y: sprite.size.height)
        
        sprite.addChild(propeller)
        
        
        let texture1 = SKTexture(imageNamed: "PLANE PROPELLER 1")
        let texture2 = SKTexture(imageNamed: "PLANE PROPELLER 2")
        
        let animate = SKAction.animate(with: [texture1, texture2], timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        
        
        propeller.run(forever, withKey: "propeller")
        
        
        
        
        
        let mv = SKAction.moveBy(x: 0, y: 300, duration: 3)
        
        //sprite.run(mv)
        
        
        
        
        
        let fade = SKAction.fadeOut(withDuration: 3)
        let gr = SKAction.sequence([mv, fade])
        
        sprite.run(gr)
        
        //propeller.position = CGPoint(x: 0, y: sprite.size.height/2)
    }
    
    func gameOver(){
        
        let flipTransition = SKTransition.fade(withDuration: 2.0)
            
            let door = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        gameOverScene.scaleMode = .aspectFill
        
        self.view?.presentScene(gameOverScene, transition: door)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        if ((contact.bodyA.categoryBitMask == PhysicsCategory.Ball && contact.bodyB.categoryBitMask == PhysicsCategory.Circle) || (contact.bodyB.categoryBitMask == PhysicsCategory.Ball && contact.bodyA.categoryBitMask == PhysicsCategory.Circle)){
            
            print("Ball touched circle")
            
            circle.removeAction(forKey: "action1")
            
            gameOver()
        }
        
        if ((contact.bodyA.categoryBitMask == PhysicsCategory.Ball && contact.bodyB.categoryBitMask == PhysicsCategory.Ground) || (contact.bodyB.categoryBitMask == PhysicsCategory.Ball && contact.bodyA.categoryBitMask == PhysicsCategory.Ground)){
            
            print("Ball touched ground")
        }
        
    }
    
    @objc func swiped(){
        
        ball.physicsBody?.affectedByGravity = true
        
    }
    
    func addPhysics(){
        
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.width/2)
        
        ball.physicsBody?.affectedByGravity = false
        //ball.physicsBody?.allowsRotation = false
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.frame.width/2)
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.isDynamic =  false
        
        
        
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 5))
        ground.physicsBody?.affectedByGravity = false
        
        ground.physicsBody?.isDynamic = false
       
        
        
    }
    
    func addBitMasks(){
        
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        ball.physicsBody?.contactTestBitMask =  PhysicsCategory.Ground
        
        circle.physicsBody?.categoryBitMask = PhysicsCategory.Circle
        circle.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        circle.physicsBody?.contactTestBitMask =  PhysicsCategory.Ball
        
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Circle
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var f = touches.first
        
        var loc = f?.location(in: self.view)
        
        //addTile(loc: loc!)
        
        
        // this is converted location using SK coordinates
        let newLoc = CGPoint(x: loc!.x, y: self.size.height-loc!.y)
        
        
        let dist = sqrt(pow(newLoc.x - circle.frame.origin.x,2)+pow(newLoc.y - circle.frame.origin.y,2))
        
        let dur = dist/200
        
        let goThere = SKAction.move(to: newLoc, duration: dur)
        
        goThere.speed = 2
        
        goThere.timingMode = .easeIn
        
        //print(goThere.duration)
        
        circle.run(goThere, withKey: "action1")
        
        
        let rot = SKAction.rotate(byAngle: Double.pi/2, duration: 1)
        
        let fade = SKAction.fadeAlpha(to: ball.alpha/2, duration: 1)
        let scale = SKAction.scale(by: 1.5, duration: 2)
        
        //ball.run(rot)
        //ball.run(fade)
        //ball.run(scale)
        
        let wait = SKAction.wait(forDuration: 5, withRange: 4)
        
        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 1)
        let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 1)
        
        let moveUp3Times = SKAction.repeat(moveUp, count: 3)
        
        let seq = SKAction.sequence([moveUp3Times, wait, moveLeft])
        
        //ball.run(seq)
        
        let grouped = SKAction.group([moveUp, wait, moveLeft])
        //ball.run(grouped)
        
        print("Grouped action duration \(grouped.duration)")
        
        print("Sequenced action duration \(seq.duration)")
        
        
        let vec = CGVector(dx: 0, dy: 100)
        
        let force = SKAction.applyForce(vec, duration: 1)
        
        //bird.physicsBody?.isDynamic = true
        
        //bird.run(force)
        
        
    }
    
    
    func addFlappyBird(){
        
       
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        var textures = [birdTexture1, birdTexture2]
        
        
        bird = SKSpriteNode(texture: birdTexture1)
        
        bird.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2+200)
        addChild(bird)
        
        bird.setScale(1.0)
        
        let animation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        
        //let animation = SKAction.animate(withNormalTextures: textures, timePerFrame: 0.1)
        let flap = SKAction.repeatForever(animation)
        
        bird.run(flap)
        
        
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.allowsRotation = false
        
    }
    
    func addMusic(){
        
        let a = SKAudioNode(fileNamed: "Pacman")
        addChild(a)
        
        let act = SKAction.play()
        
        a.run(act)
    }
    
    
    func addTile(loc: CGPoint){
        
        let tile = SKSpriteNode(imageNamed: "tile6")
        let leftOrRight = 0
        
        tile.position = CGPoint(x: loc.x, y: (self.view?.frame.height)!-loc.y)
        
        addChild(tile)
        
        //tile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: tile.frame.width, height: tile.frame.height))
        
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x:-tile.size.width/2, y:-tile.size.height/2))
        path.addLine(to: CGPoint(x:tile.size.width/2, y:-tile.size.height/2))
        path.addLine(to: CGPoint(x:CGFloat(1-leftOrRight*2)*tile.size.width/2, y:tile.size.height/2))
        path.close()
        
        
        tile.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
         
        
        tile.physicsBody?.isDynamic = false
    }

    struct PhysicsCategory {
           static let Ball: UInt32 = 1
           static let Circle: UInt32 = 2
           static let Ground: UInt32 = 4
           static let Tile: UInt32 = 8
       }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
