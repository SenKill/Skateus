           //
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by SenKill on 7/6/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}
           
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 100.0
    }
    
    enum GameState {
        case notRunning
        case running
    }
    
    enum DefaultKeys {
        static let bestResult = "highscore"
    }
    
    // Array, that contains all sections of sidewalk
    var bricks = [SKSpriteNode]()
    var gems = [SKSpriteNode]()
    let gameOverMusic = SKAudioNode(fileNamed: "lol u died.wav")
    let music = SKAudioNode(fileNamed: "music.mp3")
    
    // Size of sections of sidewalk
    var brickSize = CGSize.zero
    var brickLevel = BrickLevel.low
    var gameState = GameState.notRunning
    
    // Setting of speed, it may be increased during the game
    var scrollSpeed: CGFloat = 5.0
    var startingScrollSpeed: CGFloat = 5.0
    var gravitySpeed: CGFloat = 1.5
    
    var lastUpdateTime: TimeInterval?
    
    var score: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "backgroundDoom")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        skater.setupPhysicsBody()
        addChild(skater)
        
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        menuLayer.position = CGPoint(x: 0.0, y: 0.0)
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Press to play", score: nil)
        addChild(menuLayer)
    }
    
    func setHighscore(yourResult result: Int) {
        let defaults = UserDefaults.standard
        defaults.set(result, forKey: "highscore")
    }
    
    func getHighscore() -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: "highscore")
    }
    
    func resetSkater() {
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func setupLabels() {
        
        let scoreTextLabel: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        scoreTextLabel.text = "Score"
        scoreTextLabel.fontSize = 20.0
        scoreTextLabel.zPosition = 20
        scoreTextLabel.position = CGPoint(x: 30.0, y: frame.size.height - 20)
        scoreTextLabel.horizontalAlignmentMode = .left
        addChild(scoreTextLabel)
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 30.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        let highScoreTextLabel = SKLabelNode(text: "Highscore")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 50.0, y: frame.size.height - 20.0)
        highScoreTextLabel.fontName = "Chalkduster"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        let highScoreLabel = SKLabelNode(text: String(getHighscore()))
        highScoreLabel.position = CGPoint(x: frame.size.width - 40.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Chalkduster"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText(withHighScore highScore: Int) {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        gameOverMusic.removeFromParent()
        gameState = .running
        addChild(music)
        
        resetSkater()
        
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
        
        score = 0
    }
    
    func gameOver() {
        gameState = .notRunning
        run(SKAction.playSoundFileNamed("died.wav", waitForCompletion: false))
        music.removeFromParent()
        let currentHighScore = getHighscore()
        
        if score > currentHighScore {
            setHighscore(yourResult: score)
            updateHighScoreLabelText(withHighScore: score)
        }
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        
        menuLayer.anchorPoint = CGPoint.zero
        menuLayer.position = CGPoint.zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Game Over!", score: score)
        addChild(menuLayer)
        gameOverMusic.autoplayLooped = true
        addChild(gameOverMusic)
    }
    
    func spawnBrick (atPosition position: CGPoint) -> SKSpriteNode {
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        brickSize = brick.size
        bricks.append(brick)
        
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        return brick
    }
    
    func spawnGem(atPosition position: CGPoint) {
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        gem.removeFromParent()
        
        if let gemIndex = gems.firstIndex(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            
            if newX < -brickSize.width {
                
                brick.removeFromParent()
                
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                brick.position = CGPoint(x: newX, y: brick.position.y)
                
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = ( brickSize.height / 2.0 ) + brickLevel.rawValue
            
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 2 && score > 5 {
                let gap = 20.0 * scrollSpeed
                brickX += gap

                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                    
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            }
            else if randomNumber < 4 && score > 15 {
                if brickLevel == .high {
                    brickLevel = .low
                }
                else if brickLevel == .low {
                    brickLevel = .high
                }
            }
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        for gem in gems {
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            
            if gem.position.x < 0.0 {
                removeGem(gem)
            }
        }
    }
    
    func updateSkater() {
        if let velocityY = skater.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver && skater.isOnGround {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
            score += Int(scrollSpeed)
            lastScoreUpdateTime = currentTime
            updateScoreLabelText()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState != .running {
            return
        }
        
        var elapsedTime: TimeInterval = 0.0
        
        scrollSpeed += 0.01
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
        
        updateSkater()
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if gameState == .running {
            if skater.isOnGround {
                skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 290.0))
                run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
            }
        } else {
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                menuLayer.removeFromParent()
            }
            startGame()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            if let velocityY = skater.physicsBody?.velocity.dy {
                if !skater.isOnGround && velocityY < 100.0 {
                    skater.createSparks()
                }
            }
            skater.isOnGround = true
        }
        else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            if let gem = contact.bodyB.node as? SKSpriteNode {
                removeGem(gem)
                score += 50
                updateScoreLabelText()
                
                run(SKAction.playSoundFileNamed("gem.wav", waitForCompletion: false))
            }
        }
    }
}
