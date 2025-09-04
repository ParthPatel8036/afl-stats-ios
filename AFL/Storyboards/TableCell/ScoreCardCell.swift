//
//  ScoreCardCell.swift
//  AFL
//
//  Created by Parth on 25/05/2025.
//


import UIKit

class ScoreCardCell: UITableViewCell {
    
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title4Label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadAFLStats(stats: AFLPlayerStats, playerName: String) {
        title1Label.text = playerName
        title2Label.text = "\(stats.goals)"
        title3Label.text = "\(stats.disposals)"
        title4Label.text = "\(stats.tackles)"
    }
}

