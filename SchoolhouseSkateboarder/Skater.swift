//
//  Skater.swift
//  SchoolhouseSkateboarder
//
//  Created by SenKill on 7/6/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import SpriteKit

class Skater: SKSpriteNode {
    var velocity = CGPoint.zero
    var minimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    var isOnGround = true
}
