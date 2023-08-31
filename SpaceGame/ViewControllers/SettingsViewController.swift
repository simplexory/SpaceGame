//
//  SettingsViewController.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var playerModelSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerName = GameSetting.shared.loadName()
        
        usernameTextField.text = playerName
        addTapGesture()
    }

    @IBAction func playerModelChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            GameSetting.shared.playerImage = .first
        case 1:
            GameSetting.shared.playerImage = .second
        case 2:
            GameSetting.shared.playerImage = .third
        default:break        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if let playerName = usernameTextField.text {
            GameSetting.shared.saveName(playerName)
        }
        
        self.dismiss(animated: true)
    }
    
    private func addTapGesture() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected(_:)))
        
        self.view.addGestureRecognizer(recognizer)
    }

    @objc private func tapDetected(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
