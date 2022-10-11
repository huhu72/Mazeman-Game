//
//  GameScene.swift
//  Mazeman
//
//  Created by Spencer Kinsey-Korzym on 4/2/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var background = SKSpriteNode(imageNamed: "background")
    var rows: [[SKSpriteNode]]!
    var numRow: Int!
    var numCol: Int!
    let blockTexture = SKTexture(imageNamed: "block")
    let blockSize = CGSize(width: 64, height: 64)
    let waterTexture = SKTexture(imageNamed: "water")
    var battery: Battery!
    var playerTexture = SKTexture(imageNamed: "player")
    var playerRightTexture = SKTexture(imageNamed: "player-right")
    var player = SKSpriteNode()
    var gameStatusPanel = SKSpriteNode(texture: SKTexture(imageNamed: "panel"),
                                       size: CGSize(width: 850, height: 118))
    var swipeUpGR = UISwipeGestureRecognizer()
    var gameLabel = SKLabelNode()
    var touchPoint: CGPoint!
    var numRandomBlock = 0
    var starLabel:SKLabelNode!
    var heartLabel:SKLabelNode!
    var rockLabel:SKLabelNode!
    var batteryLabel:SKLabelNode!
    var waterPos: Int!
    var waterPos2: Int!
    var dino1: SKSpriteNode!
    var dino2: SKSpriteNode!
    var dino3: SKSpriteNode!
    var dino4: SKSpriteNode!
    var dino1Direction: SKAction!
    var dinoDY = 20
    var dino1Count = 0
    var firstContactPOS: CGPoint = CGPoint(x: 100000, y: 100000)
    var rockCount: Int!
    var starTexture =  SKTexture(imageNamed: "star")
    var foodTexture =  SKTexture(imageNamed: "food")
    var star: SKSpriteNode!
    var food: SKSpriteNode!
    var isWaterBlock1Hit: Bool = false
    var isWaterBlock2Hit: Bool = false
    var starRowIndex = 0
    var starColIndex = 0
    var foodRowIndex = 0
    var foodColIndex = 0
    var canEatFood = true
    var energy = 1.0
    var gravityCountDown: Int!
    var wait1Sec = SKAction.wait(forDuration: 1)
    var highscores: [Int] = [0,0,0]
    override func didMove(to view: SKView) {
        
        //
        //        // Create shape node to use during mouse interaction
        //        let w = (self.size.width + self.size.height) * 0.05
        //        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        //
        //        if let spinnyNode = self.spinnyNode {
        //            spinnyNode.lineWidth = 2.5
        //
        //            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        //            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
        //                                              SKAction.fadeOut(withDuration: 0.5),
        //                                              SKAction.removeFromParent()]))
        //        }
     
        setUpGame()
       // GameScene.saveData(data: [0,0,0])
        highscores = GameScene.getData()
       
        //gameOver()
    }
    func setUpGame(){
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
        numRow = Int(frame.size.height/64 - 1)
        numCol = Int(frame.size.width/64 - 1)
        rows = Array(repeating: Array(repeating: SKSpriteNode.init(),
                                      count: numCol+1), count: numRow+1)
        self.physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 64, left: 1, bottom: 128, right: 0)))
        physicsBody?.categoryBitMask = PhysicsCategory.Block
        physicsBody?.collisionBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
        // physicsBody?.isDynamic = false
        //        physicsBody?.collisionBitMask = PhysicsCategory.Player
        //        physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.view?.addGestureRecognizer(createSwipeGR(for: .up))
        self.view?.addGestureRecognizer(createSwipeGR(for: .down))
        self.view?.addGestureRecognizer(createSwipeGR(for: .left))
        self.view?.addGestureRecognizer(createSwipeGR(for: .right))
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view?.addGestureRecognizer(tapGR)
        fillBlockArray()
        addInitialBlocks()
        let spawnBlock = SKAction.run {
            self.spawnRandomBlocks()
        }
        
        let action = SKAction.group([wait1Sec,spawnBlock])
        self.run(SKAction.repeatForever(action), withKey: "spawn-blocks")
        rockCount = 10
        startTimer()
        countDownToGravity()
        let notifyGravity = SKAction.run {
            self.gameLabel.text = "Gravity starting in \(self.gravityCountDown!) seconds!"
        }
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 5), notifyGravity ])))
        
    }
    func fillBlockArray(){
        
        for i in 0...numRow{
            for j in 0...numCol{
                let block = SKSpriteNode(texture: nil, size: blockSize)
                if j == 0 {
                    block.position.x = block.frame.width/2
                    if i == 0 {
                        block.position.y = block.frame.height/2
                    }else{
                        block.position.y = rows[i-1][j].position.y + block.frame.height
                    }
                }else{
                    if i == 0{
                        block.position.y = rows[i][j-1].position.y
                    }else{
                        block.position.y = rows[i-1][j-1].position.y + block.frame.height
                    }
                    block.position.x = rows[i][j-1].position.x + block.frame.width
                }
                block.zPosition = 1
                block.name = "empty"
                rows[i][j] = block
            }
        }
        
    }
    func addInitialBlocks(){
        for j in 0...numCol{
            rows[0][j].texture = blockTexture
            rows[0][j].name = "block"
            rows[11][j].texture = blockTexture
            rows[11][j].name = "block"
            rows[10][j].texture = blockTexture
            rows[10][j].name = "block"
            
        }
        
        addBottomRowUI()
        showBlocks()
        //        for i in 0...numRow{
        //            var printStatement = "row \(i+1)"
        //            for j in 0...numCol{
        //                    printStatement = printStatement + "|\(rows[i][j].name!)"
        //            }
        //            print(printStatement)
        //        }
        showGamePanel()
        spawnPlayer()
        spawnStar()
       
        spawnDino1()
        spawnDino2()
        spawnDino3()
        spawnDino4()
        spawnFood()
        
    }
    func showBlocks(){
        for j in 0...numCol{
            addChild(rows[0][j])
        }
        for i in 10...11{
            for j in 0...numCol{
                addChild(rows[i][j])
            }
        }
        
    }
    
    func addBottomRowUI(){
        let starBlock = SKSpriteNode(texture: SKTexture(imageNamed: "star"), size: blockSize)
        starBlock.position = CGPoint(x: starBlock.frame.width/2, y: starBlock.frame.height/2)
        starBlock.zPosition = 2
        starLabel = SKLabelNode(text: "0")
        starLabel.position.x = starBlock.position.x
        starLabel.position.y = 20
        starLabel.name = starLabel.text
        starLabel.zPosition = 3
        starLabel.fontSize = 30
        starLabel.fontName = "HelveticaNeue-Bold"
        addChild(starBlock)
        addChild(starLabel)
        let rockBlock = SKSpriteNode(texture: SKTexture(imageNamed: "rock"), size: blockSize)
        var xCord = starBlock.position.x + rockBlock.frame.width
        rockBlock.position = CGPoint(x: xCord, y: rockBlock.frame.height/2)
        rockBlock.zPosition = 2
        rockLabel = SKLabelNode(text: "10")
        rockLabel.position.x = rockBlock.position.x
        rockLabel.position.y = 20
        rockLabel.zPosition = 3
        rockLabel.fontSize = 30
        rockLabel.fontName = "HelveticaNeue-Bold"
        rockLabel.name = rockLabel.text
        addChild(rockBlock)
        addChild(rockLabel)
        let heartBlock = SKSpriteNode(texture: SKTexture(imageNamed: "heart"), size: blockSize)
        xCord = rockBlock.position.x + heartBlock.frame.width
        heartBlock.position = CGPoint(x: xCord, y: rows[0][2].frame.height/2)
        heartBlock.zPosition = 2
        heartLabel = SKLabelNode(text: "3")
        heartLabel.position.x = heartBlock.position.x
        heartLabel.position.y = 20
        heartLabel.zPosition = 3
        heartLabel.fontSize = 30
        heartLabel.fontName = "HelveticaNeue-Bold"
        heartLabel.name = heartLabel.text
        addChild(heartBlock)
        addChild(heartLabel)
        self.battery = Battery.init(baseColor: .gray, energyColor: .green, size: CGSize(width: 100, height: 32))
        battery.zPosition = 2
        xCord = heartBlock.position.x + 100
        battery.position = CGPoint(x: xCord, y: 32)
        batteryLabel = SKLabelNode(text: "100")
        batteryLabel.position.x = battery.position.x
        batteryLabel.position.y = 20
        batteryLabel.zPosition = 3
        batteryLabel.fontSize = 30
        batteryLabel.fontName = "HelveticaNeue-Bold"
        batteryLabel.name = batteryLabel.text
        addChild(battery)
        addChild(batteryLabel)
        addWaterBlocks()
    }
   

    func addWaterBlocks(){
        for _ in 0...1{
            var randomIndex = Int.random(in: 5...numCol)
            while  randomIndex == waterPos{
             
                randomIndex = Int.random(in: 5...numCol)
            }
   
            if waterPos == nil{
                waterPos = randomIndex
                rows[0][randomIndex].name = "water1"
            }else{
                waterPos2 = randomIndex
                rows[0][randomIndex].name = "water2"
            }
            rows[0][randomIndex].texture = waterTexture
            
            rows[0][randomIndex].physicsBody = SKPhysicsBody(texture: waterTexture, size: CGSize(width: 64, height: 64))
            rows[0][randomIndex].physicsBody?.categoryBitMask = PhysicsCategory.Water
            rows[0][randomIndex].physicsBody?.affectedByGravity = false
            //rows[0][randomIndex].physicsBody?.contactTestBitMask = PhysicsCategory.Player
            rows[0][randomIndex].physicsBody?.restitution = 0
            rows[0][randomIndex].physicsBody?.pinned = true
            rows[0][randomIndex].physicsBody?.allowsRotation = false
            rows[0][randomIndex].physicsBody?.isDynamic = false
        }
    }
    
    func showGamePanel(){
        gameStatusPanel.position.x = rows[numRow][7].position.x + 40
        gameStatusPanel.position.y = rows[numRow-1][7].position.y + 30
        gameStatusPanel.zPosition = 2
        addChild(gameStatusPanel)
        showGameStatus()
    }
    func showGameStatus(){
        gameLabel.text = "Welcome to Mazeman, Good Luck!"
        gameLabel.position = CGPoint(x: gameStatusPanel.position.x,
                                     y: gameStatusPanel.position.y-10)
        gameLabel.zPosition = 3
        gameLabel.fontSize = 40
        gameLabel.fontName = "HelveticaNeue-Bold"
        addChild(gameLabel)
    }
    func spawnPlayer(){
        player = SKSpriteNode(texture: playerRightTexture, size: blockSize)
        player.size = blockSize
        player.name = "player"
        let initialXCord = rows[1][0].position.x
        player.position = CGPoint(x: initialXCord , y: 98)
        player.zPosition = 1
        addPhysicsToPlayer()
        
        //        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        //        player.physicsBody?.collisionBitMask =
        //        player.physicsBody?.contactTestBitMask =
        //        player.physicsBody?.affectedByGravity = false
        //        player.physicsBody?.restitution = 0
        //        player.physicsBody?.allowsRotation = false
        //        player.physicsBody?.isDynamic = true
        addChild(player)
    }
    func addPhysicsToPlayer(){
        player.physicsBody = SKPhysicsBody(texture: player.texture! , size: player.size)
        //player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask =   PhysicsCategory.Block
        player.physicsBody?.contactTestBitMask =   PhysicsCategory.Block | PhysicsCategory.Water | PhysicsCategory.Enemy | PhysicsCategory.Friendly
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.allowsRotation = false
        //player.physicsBody?.pinned = true
    }
    //    func addBitMaskToBottomRow(){
    //
    //        rows[0][0].physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -32, y: 32), to: CGPoint(x: 1000, y: 32))
    //        rows[0][0].physicsBody?.categoryBitMask = PhysicsCategory.Block
    //        rows[0][0].physicsBody?.affectedByGravity = false
    //        rows[0][0].physicsBody?.isDynamic = false
    //        //rows[0][0].physicsBody?.contactTestBitMask = PhysicsCategory.Player
    //        //        rows[0][0].physicsBody?.restitution = 0
    //        //        rows[0][1].physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -96, y: 32), to: CGPoint(x: 1000, y: 32))
    //        //        rows[0][1].physicsBody?.categoryBitMask = PhysicsCategory.Block
    //        //        rows[0][1].physicsBody?.affectedByGravity = false
    //        //        rows[0][1].physicsBody?.isDynamic = false
    //        //        //rows[0][1].physicsBody?.contactTestBitMask = PhysicsCategory.Player
    //        //        rows[0][1].physicsBody?.restitution = 0
    //
    //    }
    func createSwipeGR(for direction: UISwipeGestureRecognizer.Direction)-> UISwipeGestureRecognizer{
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(movePlayer))
        swipeGR.direction = direction
        
        return swipeGR
    }
    
    func spawnRandomBlocks(){
        let randomCol = Int.random(in: 0...numCol)
        let randomRow = Int.random(in: 1...9)
        if numRandomBlock != 15{
            if rows[randomRow][randomCol].name == "empty" && !rows[randomRow][randomCol].intersects(player) {
                numRandomBlock += 1
                rows[randomRow][randomCol].texture = blockTexture
                rows[randomRow][randomCol].name = "block"
                rows[randomRow][randomCol].physicsBody = SKPhysicsBody(texture: blockTexture, size: CGSize(width: 60, height: 60))
                rows[randomRow][randomCol].physicsBody?.categoryBitMask = PhysicsCategory.Block
                //rows[randomRow][randomCol].physicsBody?.contactTestBitMask = PhysicsCategory.Player
                rows[randomRow][randomCol].physicsBody?.affectedByGravity = false
                rows[randomRow][randomCol].physicsBody?.allowsRotation = false
                rows[randomRow][randomCol].physicsBody?.isDynamic = false
                addChild(rows[randomRow][randomCol])
            }else{
                spawnRandomBlocks()
            }
        }else{
            self.removeAction(forKey: "spawn-block")
        }
    }
    
    func spawnDino1(){
        dino1 = SKSpriteNode(imageNamed: "dino1")
        dino1.name = "dino1"
        dino1.size = CGSize(width: 64, height: 64)
        dino1.setScale(1)
        dino1.zPosition = 2
        dino1.physicsBody = SKPhysicsBody(texture: dino1.texture!, size: dino1.frame.size)
        dino1.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        dino1.physicsBody?.affectedByGravity = false
        dino1.physicsBody?.allowsRotation = false
        dino1.physicsBody?.collisionBitMask = PhysicsCategory.Player
        dino1.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        dino1.physicsBody?.isDynamic = false
        dino1.physicsBody?.restitution = 0.0
        let randomNum = Int.random(in: 1...2)
        var randomWaterPos: Int!
        if randomNum == 1{
            randomWaterPos = waterPos
        }else{
            randomWaterPos = waterPos2
        }
        
        dino1.position = CGPoint(x: rows[0][randomWaterPos].position.x, y: 64 + dino1.size.height/4)
//        dino1.position = rows[9][4].position
        addChild(dino1)
        let moveUp = SKAction.moveTo(y: 640, duration: 4)
        let moveDown = SKAction.moveTo(y: 64 + dino1.frame.height/4, duration: 4)
        let wait = SKAction.wait(forDuration: Double.random(in: 3...5))
        let animation = SKAction.repeatForever(SKAction.sequence([moveUp,moveDown,wait]))
        dino1.run(animation)
    }
    
    func spawnDino2(){
        dino2 = SKSpriteNode(imageNamed: "dino2")
        dino2.name = "dino2"
        dino2.size = CGSize(width: 64, height: 64)
        dino2.zPosition = 2
        dino2.physicsBody = SKPhysicsBody(texture: dino2.texture!, size: dino2.frame.size)
        dino2.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        dino2.physicsBody?.affectedByGravity = false
        dino2.physicsBody?.allowsRotation = false
         dino2.physicsBody?.collisionBitMask = PhysicsCategory.Player
        dino2.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        dino2.physicsBody?.isDynamic = false
        dino2.physicsBody?.restitution = 0.0
        var randomRow = Int.random(in: 1...9)
        while rows[randomRow][numCol].intersects(player){
            randomRow = Int.random(in: 1...9)
        }
        let pos = rows[randomRow][numCol].position
      // let pos = rows[1][numCol].position
        dino2.position = CGPoint(x: pos.x, y:  pos.y)
        addChild(dino2)
        let moveRight = SKAction.moveTo(x: 1024 - 32, duration: 4)
        let moveLeft = SKAction.moveTo(x: 0 + dino2.frame.height/2, duration: 4)
        let wait = SKAction.wait(forDuration: Double.random(in: 1...3))
        let animation = SKAction.repeatForever(SKAction.sequence([moveLeft,moveRight,wait]))
        dino2.run(animation)
    }
    func spawnDino3(){
        dino3 = SKSpriteNode(imageNamed: "dino3")
        dino3.name = "dino3"
        dino3.size = CGSize(width: 64, height: 64)
        dino3.zPosition = 2
        dino3.physicsBody = SKPhysicsBody(texture: dino3.texture!, size: dino3.frame.size)
        dino3.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        dino3.physicsBody?.collisionBitMask =  PhysicsCategory.Block | PhysicsCategory.Friendly
        dino3.physicsBody?.contactTestBitMask =  PhysicsCategory.Block | PhysicsCategory.Friendly | PhysicsCategory.Enemy
        dino3.physicsBody?.affectedByGravity = false
        dino3.physicsBody?.allowsRotation = false
        // dino3.physicsBody?.isDynamic = false
        dino3.physicsBody?.restitution = 0.0
        let pos = rows[9][0].position
        rows[9][0].name = "dino3"
        dino3.position = CGPoint(x: pos.x, y:  pos.y)
        addChild(dino3)
        
    }
    func spawnDino4(){
        dino4 = SKSpriteNode(imageNamed: "dino4")
        dino4.name = "dino4"
        dino4.size = CGSize(width: 128, height: 75)
        dino4.zPosition = 3
        dino4.physicsBody = SKPhysicsBody(texture: dino4.texture!, size: dino4.size)
        dino4.physicsBody?.categoryBitMask = PhysicsCategory.Dino4
        dino4.physicsBody?.collisionBitMask = 0
        dino4.physicsBody?.contactTestBitMask = 0
        dino4.physicsBody?.affectedByGravity = false
        dino4.physicsBody?.allowsRotation = false
        dino4.physicsBody?.restitution = 0.0
        let pos = rows[10][0].position
        dino4.position = CGPoint(x: pos.x, y:  pos.y)
        addChild(dino4)
        let moveRight = SKAction.moveTo(x: 1024-dino4.size.width/2, duration: 4)
        let moveLeft = SKAction.moveTo(x: dino4.size.width/2, duration: 4)
        let movement = SKAction.sequence([moveRight,moveLeft])
        let timer = SKAction.wait(forDuration: Double.random(in: 5...10))
        let fireBall = SKAction.run {
            self.spawnFireBall()
        }
        let fireSequence = SKAction.sequence([timer,fireBall])
        let action = SKAction.group([movement,fireSequence])
        //let action = SKAction.group([fireSequence])
        dino4.run(SKAction.repeatForever(action))
    }
    func spawnFireBall(){
        gameLabel.text = "INCOMING FIREBALL!"
        let fire  = SKSpriteNode(texture: SKTexture(imageNamed: "fire"), size: CGSize(width: 64, height: 64))
        fire.name = "fire"
        fire.position = CGPoint(x: dino4.position.x, y: dino4.position.y - dino4.size.height/2)
        fire.zPosition = 2
        fire.physicsBody = SKPhysicsBody(texture: fire.texture!, size: fire.size)
        fire.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        fire.physicsBody?.collisionBitMask = PhysicsCategory.Player
       fire.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        fire.physicsBody?.affectedByGravity = false
        fire.physicsBody?.isDynamic = false
        fire.physicsBody?.collisionBitMask = 0
        fire.physicsBody?.contactTestBitMask = 0
        let removeFire = SKAction.run {
            if !self.intersects(fire){
                fire.removeFromParent()
            }
        }
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -25), duration: 0.1)
        let action = SKAction.group([moveDown,removeFire])
        addChild(fire)
        fire.run(SKAction.repeatForever(action))
    }
    func moveInRandomDirection(){
        let pos = dino3.position
        let randomNum = Int.random(in: 1...4)
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 15), duration: 0.1)
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -15), duration: 0.1)
        let moveRight = SKAction.move(by: CGVector(dx: 15, dy: 0), duration: 0.1)
        let moveLeft = SKAction.move(by: CGVector(dx: -15, dy: 0), duration: 0.1)
        var animation: SKAction!
        switch(randomNum){
        case 1:
            animation = SKAction.repeatForever(moveUp)
            dino3.yScale = 1
           // print("moving up")
        case 2:
            animation = SKAction.repeatForever(moveRight)
            dino3.xScale = 1
           // print("moving right")
        case 3:
            animation = SKAction.repeatForever(moveDown)
            dino3.yScale = -1
          //  print("moving down")
        default:
            dino3.xScale = -1
            animation = SKAction.repeatForever(moveLeft)
           // print("moving left")
        }
        let didChange = SKAction.run {
            if self.dino3.position == pos{
                print("stuck")
                self.moveInRandomDirection()
            }
        }
      
        let seq = SKAction.sequence([wait1Sec,didChange])
        dino3.run(SKAction.group([seq,animation]))
    }
    func spawn(type: String){
        switch(type){
        case "dino1":
            spawnDino1()
        case "dino2":
            spawnDino2()
        case "dino3":
            spawnDino3()
        case "star":
            spawnStar()
        case "food":
            print("spawning food")
            spawnFood()
        default:
            break
        }
    }
    
    func startTimer(){
      
        let drainBattery = SKAction.run { [self] in
            if Int(batteryLabel.text!)! > 0{
                self.energy -= 0.01
                self.battery.drainBattery(self.energy)
                batteryLabel.text = String(Int(batteryLabel.text!)! - 1)
            }else{
                killPlayer()
            }
        }
        let batteryAction = SKAction.repeatForever(SKAction.sequence([wait1Sec, drainBattery]))
        let rockTimer = SKAction.wait(forDuration: 30)
        let increaseRock = SKAction.run { [self] in
            if(Int(rockLabel.text!)! < 20){
                rockLabel.text = String(Int(rockLabel.text!)! + 1)
                rockCount = Int(rockLabel.text!)!
            }
        }
        let rockAction = SKAction.repeatForever(SKAction.sequence([rockTimer,increaseRock]))
        let action = SKAction.group([batteryAction,rockAction])
        
        battery.run(action)
    }
    func killPlayer(){
//        player.removeFromParent()
//        spawnPlayer()
        self.run(SKAction.playSoundFileNamed("player-death", waitForCompletion: false))
        heartLabel.text = String(Int(heartLabel.text!)! - 1)
        if  Int(heartLabel.text!)! < 0{
            print("called")
            gameOver()
        }else{
        self.battery.drainBattery(1.0)
        self.energy = 1.0
        batteryLabel.text = "100"
        }
        
    }
    func spawnStar(){
        var randomRow = Int.random(in: 1...9)
        var randomCol = Int.random(in: 0...numCol)
        while rows[randomRow][randomCol].name != "empty" || rows[randomRow][randomCol].intersects(player) || checkIfBlockedIn(row: randomRow, col: randomCol){
            randomRow = Int.random(in: 1...9)
            randomCol = Int.random(in: 0...numCol)
        }
            starRowIndex = randomRow
            starColIndex = randomCol
        star = SKSpriteNode(texture: starTexture, size: blockSize)
        star.position = rows[randomRow][randomCol].position
        star.zPosition = 1
        rows[randomRow][randomCol].name = "star"
        star.name = "star"
        star.physicsBody = SKPhysicsBody(texture: star.texture!, size: star.size)
        star.physicsBody?.categoryBitMask = PhysicsCategory.Friendly
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.allowsRotation = false
        star.physicsBody?.restitution = 0.0
        star.physicsBody?.isDynamic = false
        addChild(star)
        
    }
    
    func spawnFood(){
        var randomRow = 6
        var randomCol = 4
//        var randomRow = Int.random(in: 1...9)
//        var randomCol = Int.random(in: 0...numCol)

        while rows[randomRow][randomCol].name != "empty" || rows[randomRow][randomCol].intersects(player) || checkIfBlockedIn(row: randomRow, col: randomCol){
            randomRow = Int.random(in: 1...9)
            randomCol = Int.random(in: 0...numCol)
        }
        foodRowIndex = randomRow
        foodColIndex = randomCol
        food = SKSpriteNode(texture: foodTexture, size: blockSize)
        food.position = rows[randomRow][randomCol].position
        food.zPosition = 1
        rows[randomRow][randomCol].name = "food"
        food.name = "food"
     
        food.physicsBody = SKPhysicsBody(texture: food.texture!, size: food.size)
        food.physicsBody?.categoryBitMask = PhysicsCategory.Friendly
        food.physicsBody?.collisionBitMask = 0
        food.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        food.physicsBody?.affectedByGravity = false
        food.physicsBody?.allowsRotation = false
        food.physicsBody?.restitution = 0.0
        //food.physicsBody?.isDynamic = false
        addChild(food)
    }
    func checkIfBlockedIn(row: Int, col: Int)->Bool{
        if row > 0 && col > 0 && col < numCol{
            //Checks all four sides
            if rows[row][col-1].name == "empty" || rows[row][col+1].name == "empty" || rows[row-1][col].name == "empty" ||
                rows[row+1][col].name == "empty"{
                return false
            }
            else{
                return true
            }
        }
        //Check top, right, and below
        if col == 0 && row < 9{
            if rows[row+1][col].name == "empty" || rows[row][col+1].name == "empty" || rows[row-1][col].name == "empty" {
                return false
            }
            else{
                return true
            }
        //Check right and below
        }else if col == 0 && row == 9 {
            if rows[row-1][col].name == "empty" || rows[row][col+1].name == "empty" {
                return false
            }
            else{
                return true
            }
        }
        //Checks top, left, and below
        if col == numCol && row < 9{
            if rows[row+1][col].name == "empty" || rows[row][col-1].name == "empty" || rows[row-1][col].name == "empty" {
                return false
            }
            else{
                return true
            }
        //CHecks left and below
        }else if col == numCol && row == 9 {
            if rows[row-1][col].name == "empty" || rows[row][col-1].name == "empty" {
                return false
            }
            else{
                return true
            }
        }
        return false
    }
    func countDownToGravity(){
        gravityCountDown = Int.random(in: 40...60)
      
        let updateGravityCounter = SKAction.run{
            self.gravityCountDown -= 1
        }
        let notifyGravity = SKAction.run {
            if self.gravityCountDown <= 7{
                self.gameLabel.text = "Gravity starting in \(self.gravityCountDown!)!"
            }
            if self.gravityCountDown <= 0{
                self.gameLabel.text = "You are now effected by gravity!"
                self.player.physicsBody?.affectedByGravity = true
            }
        }
        let gravityOff = SKAction.run {
            
            if self.gravityCountDown <= 0{
                
                self.player.physicsBody?.affectedByGravity = false
                self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                self.gravityCountDown = Int.random(in: 40...60)
                self.gameLabel.text = "Gravity will start in \(self.gravityCountDown!) seconds!"
            }
        }
        let turnOffGravity = SKAction.sequence([wait1Sec, gravityOff])

        self.run(SKAction.repeatForever(SKAction.repeat( SKAction.group([SKAction.sequence([updateGravityCounter, wait1Sec]), notifyGravity, turnOffGravity]), count: self.gravityCountDown)))
    }
        
    @objc func movePlayer(_ sender: UISwipeGestureRecognizer){
        var moveDirection:SKAction = SKAction()
        switch(sender.direction){
        case .up:
            moveDirection = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 0.1)
        case .down:
            moveDirection = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 0.1)
        case .left:
            if player.texture != playerTexture{
                player.texture = playerTexture
                // print(player.physicsBody?.collisionBitMask)
                // addPhysicsToPlayer()
            }
            moveDirection = SKAction.move(by: CGVector(dx: -10, dy: 0), duration: 0.1)
        case .right:
            if player.texture != playerRightTexture{
                player.texture = playerRightTexture
                // addPhysicsToPlayer()
            }
            player.removeAllActions()
            moveDirection = SKAction.move(by: CGVector(dx: 10, dy: 0), duration: 0.1)
        default:
            break
        }
        let action = SKAction.repeatForever(SKAction.group([moveDirection]))
        player.run(SKAction.repeatForever(action), withKey: "move")
        
    }
    @objc func tap(recognizer: UIGestureRecognizer){
        rockCount -= 1
        if rockCount >= 0 {
            rockLabel.text = String(Int(rockLabel.text!)! - 1)
            let viewLocation = recognizer.location(in: view)
            let touchPoint = convertPoint(fromView: viewLocation)
            let  rock = SKSpriteNode(texture: SKTexture(imageNamed: "rock"), size: blockSize)
            rock.position.x = player.position.x
            rock.position.y = player.position.y
            rock.setScale(0.50)
            rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
            rock.physicsBody?.categoryBitMask = PhysicsCategory.Rock
            rock.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            rock.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
            rock.zPosition = 1
            rock.physicsBody?.allowsRotation = false
            //rock.physicsBody?.isDynamic = false
            rock.physicsBody?.affectedByGravity = false
            
            addChild(rock)
            let Δy = touchPoint.y - rock.position.y
            // print("Δy: \(Δy)")
            let Δx = touchPoint.x - rock.position.x
            // print("Δx: \(Δx)")
            let velocity = 500.0
            let distance = sqrt(pow(Δx,2) + pow(Δy,2))
            // print("total distance: \(distance)")
            let duration = distance/velocity
            // print("duration: \(duration)")
            //rock.physicsBody?.velocity = CGVector(dx: Δx/duration, dy: Δy/duration)
            let removeRock = SKAction.run {
                if !self.intersects(rock){
                    rock.removeFromParent()
                }
            }
            let action = SKAction.group([SKAction.move(by: CGVector(dx: Δx/duration, dy: Δy/duration), duration: 1), removeRock])
            //rock.physicsBody?.velocity = CGVector(dx: Δx, dy: Δy)
            //SKAction.repeatForever(SKAction.move(by: CGVector(dx: Δx/duration, dy: Δy/duration), duration: 2))
            rock.run(SKAction.repeatForever(action))
        }
    }
    //Dino 3 not eatting foood
    func didBegin(_ contact: SKPhysicsContact) {
        var player: SKSpriteNode! = nil
        var rock: SKSpriteNode! = nil
        var enemy: SKSpriteNode! = nil
        var friendly: SKSpriteNode! = nil
        var water: SKSpriteNode! = nil
        var bound: SKPhysicsBody! = nil
        switch(contact.bodyA.categoryBitMask){
        case PhysicsCategory.Player:
            player = contact.bodyA.node as? SKSpriteNode
        case PhysicsCategory.Enemy:
            enemy = contact.bodyA.node as? SKSpriteNode
        case PhysicsCategory.Rock:
            rock = contact.bodyA.node as? SKSpriteNode
        case PhysicsCategory.Friendly:
            friendly = contact.bodyA.node as? SKSpriteNode
        case PhysicsCategory.Water:
            water = contact.bodyA.node as? SKSpriteNode
        case PhysicsCategory.Block:
            bound = contact.bodyA
        default:
            break
        }
        switch(contact.bodyB.categoryBitMask){
        case PhysicsCategory.Player:
            player = contact.bodyB.node as? SKSpriteNode
        case PhysicsCategory.Enemy:
            enemy = contact.bodyB.node as? SKSpriteNode
        case PhysicsCategory.Rock:
            rock = contact.bodyB.node as? SKSpriteNode
        case PhysicsCategory.Friendly:
            friendly = contact.bodyB.node as? SKSpriteNode
        case PhysicsCategory.Water:
            water = contact.bodyB.node as? SKSpriteNode
        case PhysicsCategory.Block:
            bound = contact.bodyB
        default:
            break
        }

        //Rock killing enemy
        if rock != nil{
            killEnemies(rock: rock, enemy: enemy)
            return
        }
        
        //Dino3 changing direction
        if enemy != nil && enemy.name == "dino3"{
            dino3.removeAllActions()
            moveInRandomDirection()
        }
        //Player hitting water/block
        if player != nil && (water != nil || bound != nil){
            if water == nil{
                if bound.node?.name == "block"{
                    gameLabel.text = "Oops looks like you hit a block!"
                }else{
                    gameLabel.text = "Oops looks like you have hit the edge"
                }
                self.player.removeAllActions()
               
            }else{
                gameLabel.text = "Yikes! You've just touched the water!"
                if !isWaterBlock1Hit || !isWaterBlock2Hit{
                    let resetWater = SKAction.run {
                        self.isWaterBlock2Hit = false
                        self.isWaterBlock1Hit = false
                    }
                  
                    
                    if water.name == "water1" && !isWaterBlock1Hit{
                        isWaterBlock1Hit = true
                        isWaterBlock2Hit = false
                        killPlayer()
                    }
                    if water.name == "water2" && !isWaterBlock2Hit {
                        isWaterBlock1Hit = false
                        isWaterBlock2Hit = true
                        killPlayer()
                    }
                    self.run(SKAction.sequence([wait1Sec,resetWater]))
                }
           
            }
        }

        //Player and enemy consuming star/food
        if friendly != nil && friendly.parent != nil{

            if player != nil{
                playerEat(player: player, food:friendly)
            }
            if enemy != nil && enemy.name != "dino4" && enemy.name != "fire"{
                dinoEat(dino: enemy, food: friendly)
            }
        }
        //Player contacting enemy
        if player != nil && enemy != nil {
            playerDamaged(player: player, enemy: enemy)
        }
    }

    func killEnemies(rock: SKSpriteNode, enemy: SKSpriteNode){
        if enemy.parent != nil {
            gameLabel.text = "\(enemy.name!.capitalized) killed!"
            enemy.removeFromParent()
            let wait = SKAction.wait(forDuration: Double.random(in: 1...5))
            let spawnEnemy = SKAction.run {
                self.spawn(type: (enemy.name)!)
            }
            let action = SKAction.group([SKAction.playSoundFileNamed("enemy-death", waitForCompletion: false), SKAction.sequence([wait,spawnEnemy])])
            self.run(action)

        }
        
    }
    
    func playerEat(player: SKSpriteNode, food:SKSpriteNode){
        switch(food.name){
        case "star":
            gameLabel.text = "+1 Point!"
            starLabel.text = String(Int(starLabel.text!)! + 1)
            rows[starRowIndex][starColIndex].name = "empty"
            star.removeFromParent()
            self.run(SKAction.playSoundFileNamed("get-coin", waitForCompletion: false))
        case "food":
            self.run(SKAction.playSoundFileNamed("eatting", waitForCompletion: false))
            rows[foodRowIndex][foodColIndex].name = "empty"
            self.food.removeFromParent()
            var potentialEnergy = Int(batteryLabel.text!)! + 50
            if Int(heartLabel.text!)! < 3{
                if potentialEnergy > 100{
                    gameLabel.text = "+1 Heart!"
                    heartLabel.text = String(Int(heartLabel.text!)! + 1)
                    potentialEnergy -= 100
                    batteryLabel.text = String(potentialEnergy)
                    self.battery.drainBattery(CGFloat(potentialEnergy)/100)
                    self.energy = CGFloat(potentialEnergy)/100
                }else{
                    gameLabel.text = "+50 Energy!"
                    self.battery.drainBattery(CGFloat(potentialEnergy)/100)
                    batteryLabel.text = String(potentialEnergy)
                    self.energy = CGFloat(potentialEnergy)/100
                }
            }else{
                gameLabel.text = "+50 Energy!"
                if potentialEnergy > 100{
                    batteryLabel.text = "100"
                    self.battery.drainBattery(1.0)
                    self.energy = 1.0
                }else{
                    batteryLabel.text = String(potentialEnergy)
                    self.battery.drainBattery(CGFloat(potentialEnergy)/100)
                    self.energy = CGFloat(potentialEnergy)/100
                }
            }
    
        default:
            break
        }
        spawn(type: food.name!)
            
    }
    func dinoEat(dino: SKSpriteNode, food: SKSpriteNode){
        if dino.name != "fire" && food.name == "food"{
            self.run(SKAction.playSoundFileNamed("eatting", waitForCompletion: false))
            self.food.removeFromParent()
            gameLabel.text = "\(dino.name!.capitalized) ate the food!"
            let wait = SKAction.wait(forDuration: 10)
            let spawnFood = SKAction.run {
                self.spawn(type: "food")
            }
            self.run(SKAction.sequence([wait,spawnFood]))
        }
    }
    
    func playerDamaged(player: SKSpriteNode, enemy:SKSpriteNode){
        let tempEnemyPB = enemy.physicsBody

        gameLabel.text = "Oh no! It looks like you hit \(enemy.name!)"
        player.removeAllActions()
        enemy.physicsBody = nil
        var damageToPlayer:Int! = 0
        switch(enemy.name){
        case "dino1":
            damageToPlayer = 60
        case "dino2":
            damageToPlayer = 80
        case "dino3", "fire":
            damageToPlayer = 100
            
        default:
            break
        }
        let playerHealth = Int(batteryLabel.text!)! - damageToPlayer
        //            print(playerHealth)
        //            print(damageToPlayer)
        batteryLabel.text = "\(playerHealth)"
        self.energy = Double(playerHealth)/100.0
        self.battery.drainBattery(energy)
        if Int(batteryLabel.text!)! > 0{
            self.run(SKAction.playSoundFileNamed("player-hit", waitForCompletion: false))
        }else{
            killPlayer()
        }
        let deathWaring = SKAction.run {
            if Int(self.batteryLabel.text!)! <= 40{
                self.gameLabel.text = "Looks like you need to eat some food"
            }
        }
        let resetEnemyPhysics = SKAction.run {
            enemy.physicsBody = tempEnemyPB
            if enemy.name == "dino3"{
                enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Friendly | PhysicsCategory.Enemy
                enemy.physicsBody?.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Friendly
            }else{
                enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                enemy.physicsBody?.collisionBitMask = PhysicsCategory.Player
            }
        }
        SKAction.group([SKAction.sequence([SKAction.wait(forDuration: 0.5), resetEnemyPhysics]), SKAction.sequence([wait1Sec, deathWaring])])
        self.run(        SKAction.group([SKAction.sequence([SKAction.wait(forDuration: 0.5), resetEnemyPhysics]), SKAction.sequence([wait1Sec, deathWaring])]))
    }
    func gameOver(){
        let flipTransition = SKTransition.fade(withDuration: 1.0)
        highscores.append(Int(starLabel.text!)!)
        highscores = highscores.sorted{ $0 > $1}
        let gameOverScene = GameOverScene(size: self.size, score: Int(starLabel.text!)!, hs: highscores)
        GameScene.saveData(data: highscores)
       
        gameOverScene.scaleMode = .aspectFill
            self.view?.presentScene(gameOverScene, transition: flipTransition)
    }
    override func update(_ currentTime: TimeInterval) {
        if !dino3.intersects(self){
            dino3.removeFromParent()
            spawnDino3()
        }
   

    }
    static func saveData(data: [Int]){
        let encodedData = try! JSONEncoder().encode(data)
        UserDefaults.standard.set(encodedData, forKey: "high-score")
    }
    static func getData()->[Int]{
        if(UserDefaults.standard.data(forKey: "high-score") != nil){
            let data = UserDefaults.standard.data(forKey: "high-score")
            let decodedData = try? JSONDecoder().decode([Int].self, from: data!)
            return decodedData!
        }else{
            return [0,0,0]
        }
        
    }
}

class Battery: SKNode{
    var baseSprite: SKSpriteNode!
    var energySprite: SKSpriteNode!
    
    override init() {
        super.init()
    }
    convenience init( baseColor: SKColor, energyColor: SKColor, size: CGSize){
        self.init()
        self.baseSprite = SKSpriteNode(color: baseColor, size: size)
        self.energySprite = SKSpriteNode(color: energyColor, size: size)
        self.addChild(baseSprite)
        self.addChild(energySprite)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drainBattery(_ value:CGFloat){
        guard 0.0 ... 1.0 ~= value else{return}
        let originalSize = self.baseSprite.size
        var drain: CGFloat = 0
        self.energySprite.position = self.baseSprite.position
        if value == 0.0{
            drain = originalSize.width
        }else if 0.01..<1.0 ~= value{
            drain = originalSize.width - (originalSize.width * value)
        }
        self.energySprite.size = CGSize(width: originalSize.width - drain, height: originalSize.height)
        if value > 0.0 && value < 1.0{
            self.energySprite.position = CGPoint(x: (self.energySprite.position.x - drain)/2, y: self.energySprite.position.y)
        }
        if self.energySprite.size.width <= 0.4 * originalSize.width {
            self.energySprite.color = .red
        }else if self.energySprite.size.width <= 0.7 * originalSize.width && self.energySprite.size.width > 0.3 * originalSize.width{
            self.energySprite.color = .orange
        }else{
            self.energySprite.color = .green
        }
    }
}
struct PhysicsCategory {
    static let Player: UInt32 = 0x1 << 0
    static let Block: UInt32 = 0x1 << 1
    static let Water: UInt32 = 0x1 << 2
    static let Enemy: UInt32 = 0x1 << 3
    static let Rock: UInt32 = 0x1 << 4
    static let Dino4: UInt32 = 0x1 << 5
    static let Friendly: UInt32 = 0x1 << 6
}


//        if(contact.bodyA.categoryBitMask == PhysicsCategory.Player ||
//           contact.bodyB.categoryBitMask == PhysicsCategory.Player){
//            print("called")
//            var bodyA: UInt32 = 0x0
//            switch(contact.bodyA.categoryBitMask){
//            case  :
//                bodyA = contact.bodyA.categoryBitMask
//            case PhysicsCategory.Water:
//                bodyA = contact.bodyA.categoryBitMask
//            default:
//                break
//            }
//            if bodyA == PhysicsCategory.Water{
//                self.player.removeFromParent()
//                spawnPlayer()
//            }else{
//
//                self.player.removeAllActions()
//
//            }
//        }

