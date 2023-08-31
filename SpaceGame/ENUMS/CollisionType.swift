//
//  CollisionType.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 31.08.23.
//

import Foundation

enum CollisionType: UInt32 {
    case player = 2
    case enemy = 4
    case playerWeapon = 8
    case enemyWeapon = 16
}
