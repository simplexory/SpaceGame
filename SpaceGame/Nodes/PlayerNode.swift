//
//  PlayerNode.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import Foundation
import SpriteKit

final class PlayerNode: SKSpriteNode {
    var lastFireTime: Double = 0
    var shields: Int = 10
    
    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: PlayerImages.first.rawValue)
        let size = CGSize(width: texture.size().width / 10, height: texture.size().height / 10)
        
        super.init(texture: texture, color: .white, size: size)
        
        self.name = "player"
        self.position = position
        self.zPosition = 1
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        self.physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fire() {
        let bullet = SKSpriteNode(imageNamed: "playerWeapon")
        bullet.name = "bullet"
        bullet.position = position
        bullet.zRotation = zRotation
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        bullet.physicsBody?.mass = 0.001
        
        let speed: CGFloat = 1
        let adjustedRotation = zRotation * CGFloat.pi / 2
        
        let dx = speed * sin(adjustedRotation)
        let dy = speed * cos(adjustedRotation)
        parent?.addChild(bullet)
        bullet.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak bullet] in
            bullet?.removeFromParent()
        }
    }
    
    func reloadTexture(imageName: PlayerImages) {
        let texture = SKTexture(imageNamed: imageName.rawValue)
        let size = CGSize(width: texture.size().width / 10, height: texture.size().height / 10)
        
        self.size = size
        self.texture = texture
        self.zPosition = 1
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        self.physicsBody?.isDynamic = false
    }
}
