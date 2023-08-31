//
//  Wave.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import Foundation

struct Wave: Codable {
    struct WaveEnemy: Codable {
        let position: Int
        let yOffset: CGFloat
        let moveStraight: Bool
    }
    
    let name: String
    let enemies: [WaveEnemy]
}
