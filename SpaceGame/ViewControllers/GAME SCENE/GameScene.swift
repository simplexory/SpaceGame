//
//  GameScene.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    let gameSettings = GameSetting.shared
    let restartLabel = SKLabelNode()
    let backLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let shieldsLabel = SKLabelNode()
    var sceneView: GameViewController?
    let player = PlayerNode(position: CGPoint(x: 0, y: 0))
    let playerEngine = SKEmitterNode(fileNamed: "Engine")
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(
            from: -200,
            through: 200,
            by: 200 / 10
        ))
    var width: CGFloat = 0
    var levelNumber = 0
    var waveNumber = 0
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    init(width: CGFloat) {
        super.init()
        self.width = width
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func backToMainMenu() {
        guard let gameViewController = sceneView else { return }
        gameViewController.back()
    }
    
    fileprivate func saveMatch() {
        let match = Match(
            name: gameSettings.loadName(),
            score: score,
            playerImage: gameSettings.playerImage
        )
        gameSettings.saveMatch(match: match)
    }
    
    func gameOver() {
        self.isPaused = true
        addChild(restartLabel)
        addChild(backLabel)
        
        let enemys = children.compactMap { $0 as? EnemyNode }
        enemys.forEach { enemy in
            enemy.removeFromParent()
        }
        
        saveMatch()
    }
    
    func restart() {
        restartLabel.removeFromParent()
        backLabel.removeFromParent()
        configurePlayerNode()
        configurePlayerEngineEmitter()
        score = 0
        player.shields = 10
        updateShields(number: player.shields)
        levelNumber = 0
        waveNumber = 0
        self.isPaused = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNode = atPoint(location)
                if touchedNode.name == "restart" {
                    restart()
                }
                if touchedNode.name == "back" {
                    backToMainMenu()
                }
            }
        } else {
            for touch in touches {
                let location = touch.location(in: self)
                if location.x < 0 {
                    playerMove(direction: .left)
                } else {
                    playerMove(direction: .right)
                }
            }
        }
    }
    
    func playerMove(direction: PlayerMovement) {
        let step = frame.width / 10
        
        switch direction {
        case .left:
            guard !(player.position.x - step < frame.minX + player.frame.width) else { return }
            let movement = SKAction.move(by: CGVector(dx: -step, dy: 0), duration: 0.2)
            
            player.run(movement)
            playerEngine?.run(movement)
        case .right:
            guard !(player.position.x + step > frame.maxX - player.frame.width) else { return }
            let movement = SKAction.move(by: CGVector(dx: +step, dy: 0), duration: 0.2)
            
            player.run(movement)
            playerEngine?.run(movement)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            
            player.shields -= 1
            updateShields(number: player.shields)
            
            if player.shields == 0 {
                gameOver()
                secondNode.removeFromParent()
                playerEngine?.removeFromParent()
            }
            
            firstNode.removeFromParent()
        } else if let enemy = firstNode as? EnemyNode {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            
            enemy.removeFromParent()
            secondNode.removeFromParent()
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            
            score += 5
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        
        configureSpaceEmitter()
        configurePlayerNode()
        configurePlayerEngineEmitter()
        configureLabels()
        configureGameOverLabels()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.frame.maxY < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }
        
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        
        if activeEnemies.isEmpty {
            createWave()
        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else { continue }
            
            if enemy.lastFireTime + 0.5 < currentTime {
                enemy.lastFireTime = currentTime
                
                if Int.random(in: 0...3) == 3 {
                    enemy.fire()
                }
            }
        }
        
        if player.lastFireTime + 0.2 < currentTime {
            player.lastFireTime = currentTime
            
            player.fire()
        }
    }
    
    func createWave() {
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        let enemyOffsetY: CGFloat = 20
        let enemyStartY = Int(frame.maxY)
        
        if currentWave.enemies.isEmpty {
            for (index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(
                    type: enemyTypes[enemyType],
                    startPositon: CGPoint(x: position, y: enemyStartY),
                    yOffset: enemyOffsetY * CGFloat(index * 2),
                    moveStraight: true
                )
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(
                    type: enemyTypes[enemyType],
                    startPositon: CGPoint(x: positions[enemy.position], y: enemyStartY),
                    yOffset: enemyOffsetY * enemy.yOffset,
                    moveStraight: enemy.moveStraight
                )
                addChild(node)
            }
        }
    }
    
    fileprivate func configureGameOverLabels() {
        restartLabel.text = "RESTART"
        restartLabel.name = "restart"
        restartLabel.fontSize = 25
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(
            x: 0,
            y: 0 - restartLabel.frame.height - 10
        )
        
        backLabel.text = "BACK"
        backLabel.name = "back"
        backLabel.fontSize = 25
        backLabel.fontColor = .white
        backLabel.position = CGPoint(
            x: 0,
            y: 0 + backLabel.frame.height + 10
        )
    }
    private func updateShields(number: Int) {
        shieldsLabel.text = String("\(number) : SHIELDS")
    }
    
    fileprivate func configureSpaceEmitter() {
        /// Space Emitter
        if let particle = SKEmitterNode(fileNamed: "Stars") {
            particle.position = CGPoint(x: 0, y: (self.view?.frame.height ?? 0) / 2)
            particle.particlePositionRange = CGVector(dx: self.view?.frame.width ?? 0, dy: 0)
            particle.zPosition = -1
            particle.advanceSimulationTime(10)
            addChild(particle)
        }
    }
    
    fileprivate func configurePlayerNode() {
        ///  Player Node
        player.reloadTexture(imageName: gameSettings.playerImage)
        player.position.y = frame.minY + player.size.height + frame.height / 12
        addChild(player)
    }
    
    fileprivate func configurePlayerEngineEmitter() {
        /// Player enginne emitter
        guard let playerEngine else { return }
        
        playerEngine.position = CGPoint(
            x: player.position.x,
            y: player.position.y - player.size.height / 2
        )
        playerEngine.particlePositionRange = CGVector(dx: player.size.width / 2, dy: 0)
        playerEngine.zPosition = 1
        addChild(playerEngine)
    }
    
    fileprivate func configureLabels() {
        addChild(scoreLabel)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(
            x: -(self.frame.width / 2) + scoreLabel.frame.width + 20,
            y: -(self.frame.height / 2) + scoreLabel.frame.height + 5
        )
        self.score = 0
        
        addChild(shieldsLabel)
        shieldsLabel.text = "10 : SHIELDS"
        shieldsLabel.fontSize = 22
        shieldsLabel.fontColor = .white
        shieldsLabel.position = CGPoint(
            x: self.frame.width / 2 - shieldsLabel.frame.width - 20,
            y: -(self.frame.height / 2) + shieldsLabel.frame.height + 5
        )
    }
}
