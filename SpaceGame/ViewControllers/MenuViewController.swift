//
//  MenuViewController.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import UIKit

final class MenuViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var scoreButton: UIButton!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case playButton:
            play()
        case settingsButton:
            settings()
        case scoreButton:
            score()
        default:
            break
        }
    }
    
    private func play() {
        guard let controller = storyboard?
            .instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        show(controller, sender: self)
    }
    
    private func settings() {
        guard let controller = storyboard?
            .instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        show(controller, sender: self)
    }
    
    private func score() {
        guard let controller = storyboard?
            .instantiateViewController(withIdentifier: "ScoresViewController") as? ScoresViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        show(controller, sender: self)
    }
}
