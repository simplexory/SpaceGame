//
//  EnemyNode.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import Foundation
import SpriteKit

final class EnemyNode: SKSpriteNode {
    var type: EnemyType
    var lastFireTime: Double = 0
    var shields: Int
    
    init(type: EnemyType, startPositon: CGPoint, yOffset: CGFloat, moveStraight: Bool) {
        self.type = type
        self.shields = type.shields
        
        let texture = SKTexture(imageNamed: type.name)
        let size = CGSize(width: texture.size().width / 3, height: texture.size().height / 3)
        super.init(texture: texture, color: .white, size: size)
        
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.isDynamic = false
        zPosition = 1
        
        name = "enemy"
        position = CGPoint(x: startPositon.x, y: startPositon.y + yOffset)
        
        configureMovement(moveStraight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("cannot spawn enemy")
    }
    
    func configureMovement(_ moveStraight: Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if moveStraight {
            path.addLine(to: CGPoint(x: 0, y: -3000))
        } else {
            path.addCurve(
                to: CGPoint(x: 0, y: -1000),
                controlPoint1: CGPoint(x: -position.x * 3, y: 0),
                controlPoint2: CGPoint(x: -position.x, y: -1000)
            )
        }
        
        let movement = SKAction.follow(
            path.cgPath,
            asOffset: true,
            orientToPath: true,
            speed: type.speed
        )
        
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        
        run(sequence)
    }
    
    func fire() {
        let weaponType = "\(type.name)Weapon"
        
        let bullet = SKSpriteNode(imageNamed: weaponType)
        bullet.name = "bullet"
        bullet.position = position
        bullet.zRotation = zRotation
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = CollisionType.enemyWeapon.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        bullet.physicsBody?.mass = 0.001
        
        let speed: CGFloat = 1
        let adjustedRotation = zRotation * CGFloat.pi / 2
        
        let dx = speed * cos(adjustedRotation)
        let dy = speed * sin(adjustedRotation)
        parent?.addChild(bullet)
        bullet.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak bullet] in
            bullet?.removeFromParent()
        }
    }
}
