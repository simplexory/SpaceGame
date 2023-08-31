//
//  SettingsViewController.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import UIKit

final class ScoresViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scoreTableView: UITableView!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension ScoresViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let matches = GameSetting.shared.matches else { return 0 }
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let matches = GameSetting.shared.matches,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: MatchViewCell.identifier,
                for: indexPath) as? MatchViewCell else { return UITableViewCell() }
        
        cell.configureCell(
            score: matches[indexPath.row].name,
            username: String(matches[indexPath.row].score),
            shipImage: matches[indexPath.row].playerImage
        )
        
        return cell
    }
    
    
}
