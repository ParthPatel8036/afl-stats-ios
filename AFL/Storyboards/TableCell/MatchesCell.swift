//
//  MatchesCell.swift
//  AFL
//
//  Created by Parth on 21/05/2025.
//

import UIKit

class MatchesCell: UITableViewCell {
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadMatch(match: Match) {
        teamNameLabel.text = "\(match.team1) vs \(match.team2)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let formattedDate = dateFormatter.string(from: match.date)
        dateLabel.text = formattedDate
    }
    
}
