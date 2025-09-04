//
//  SectionHeaderCell.swift
//  AFL
//
//  Created by Parth on 25/05/2025.
//


import UIKit

class SectionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title4Label: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpForAFLStats() {
        title1Label.text = "PLAYER"
        title2Label.text = "GOALS"
        title3Label.text = "DISPOSALS"
        title4Label.text = "TACKLES"
        mainView.backgroundColor = UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)
    }
    
    func loadAFLStats(stats: AFLPlayerStats, playerName: String) {
        title1Label.text = playerName
        title2Label.text = "\(stats.goals)"
        title3Label.text = "\(stats.disposals)"
        title4Label.text = "\(stats.tackles)"
        
        title1Label.textColor = .black
        title2Label.textColor = .black
        title3Label.textColor = .black
        title4Label.textColor = .black
        
        mainView.backgroundColor = .clear
    }
}
