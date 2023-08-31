//
//  EnemyType.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import Foundation

struct EnemyType: Codable {
    let name: String
    let shields: Int
    let speed: CGFloat
    let powerUpChance: Int
}
