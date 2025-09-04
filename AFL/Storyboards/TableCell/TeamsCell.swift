//
//  TeamsCell.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import UIKit
protocol TeamsCellDelegate: AnyObject {
    func deleteTapped(teamObj: Team?)
    func editTapped(teamObj: Team?)
    func checkBoxTapped(teamObj: Team?)
}

class TeamsCell: UITableViewCell {
    
    @IBOutlet weak var titleTLabel: UILabel!
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var checkBoxTrailing: NSLayoutConstraint!
    @IBOutlet weak var checkBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var deleteBtn: UIButton!
    weak var delegate: TeamsCellDelegate?
    var teamObject: Team?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setTeamData(obj: Team?, selectedT: [Team]) {
        teamObject = obj
        if selectedT.contains(where: {$0.documentID == obj?.documentID}) {
            checkBoxImage.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            checkBoxImage.image = UIImage(systemName: "square")
        }
        titleTLabel.textColor = .white
        titleTLabel.text = obj?.name
        checkBoxWidth.constant = 24
        checkBoxTrailing.constant = 4
        checkBoxView.alpha = 1
        backgroundColor = UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)
    }
    
    func setPlayersData(obj: Player?, teamObj: Team?) {
        checkBoxWidth.constant = 0
        checkBoxTrailing.constant = 0
        checkBoxView.alpha = 0
        teamObject = teamObj
        titleTLabel.text = "\(obj?.name ?? "Player") - (\(obj?.jerseyNumber ?? 0))"
        titleTLabel.textColor = .black
        backgroundColor = UIColor.systemBackground
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        delegate?.deleteTapped(teamObj: teamObject)
    }
    
    @IBAction func editBtn(_ sender: Any) {
        delegate?.editTapped(teamObj: teamObject)
    }
    
    @IBAction func checkMarkBtn(_ sender: Any) {
        delegate?.checkBoxTapped(teamObj: teamObject)
    }

}
