//
//  MenuLayer.swift
//  SchoolhouseSkateboarder
//
//  Created by SenKill on 7/12/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import SpriteKit

class MenuLayer: SKSpriteNode {
    func display(message: String, score: Int?) {
        let messageLabel = SKLabelNode(text: message)
        
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Chalkduster"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        addChild(messageLabel)
        
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        if let scoreToDisplay = score {
            let scoreString = String(format: "Scores:%04d", scoreToDisplay)
            let scoreLabel = SKLabelNode(text: scoreString)
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Chalkduster"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }
}
