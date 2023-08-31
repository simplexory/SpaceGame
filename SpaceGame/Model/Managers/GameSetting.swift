//
//  GameSetting.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 31.08.23.
//

import Foundation

private extension String {
    static let playerNameKey = "playerNameKey"
    static let matchKey = "matchKey"
}

final class GameSetting {
    static let shared = GameSetting()
    
    var playerImage: PlayerImages = .first
    var matches: [Match]?
    
    init() {
        updateMatches()
    }
    
    private func updateMatches() {
        self.matches = loadMatches()
    }
    
    func saveName(_ name: String) {
        UserDefaults.standard.set(name, forKey: .playerNameKey)
    }
    
    func loadName() -> String {
        guard let name = UserDefaults.standard.object(forKey: .playerNameKey) as? String else { return "Player" }
        return name
    }
    
    func saveMatch(match: Match) {
        if match.score != 0 {
            if self.matches == nil {
                var matches: [Match] = []
                matches.append(match)
                UserDefaults.standard.set(encodable: matches, forKey: .matchKey)
                updateMatches()
            } else {
                self.matches?.append(match)
                self.matches = self.matches?.sorted { $0.score > $1.score }
                UserDefaults.standard.set(encodable: self.matches, forKey: .matchKey)
            }
        }
    }
    
    func loadMatches() -> [Match]? {
        guard let matches = UserDefaults.standard.value([Match].self, forKey: .matchKey) else { return nil }
        return matches
    }
    
    func removeAll() {
        UserDefaults.standard.removeObject(forKey: .matchKey)
    }
}
