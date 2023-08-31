//
//  MatchViewCell.swift
//  SpaceGame
//
//  Created by Юра Ганкович on 30.08.23.
//

import UIKit

final class MatchViewCell: UITableViewCell {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var shipImageView: UIImageView!
    
    static let identifier = "MatchViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(score: String, username: String, shipImage: PlayerImages) {
        scoreLabel.text = score
        usernameLabel.text = username
        shipImageView.image = UIImage(named: shipImage.rawValue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
