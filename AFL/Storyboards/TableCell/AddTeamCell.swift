//
//  AddTeamCell.swift
//  AFL
//
//  Created by Parth on 25/05/2025.
//

import UIKit
protocol AddTeamCellDelegate: AnyObject {
    func deletePlayer(cell: AddTeamCell)
    func updateObject(cell: AddTeamCell)
}

class AddTeamCell: UITableViewCell {
    
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerNameField: UITextField!
    @IBOutlet weak var playerNameJerseyField: UITextField!
    weak var delegate: AddTeamCellDelegate?
    var index = -1
    var playerObj = Player()
    override func awakeFromNib() {
        super.awakeFromNib()
        playerNameField.delegate = self
        playerNameJerseyField.delegate = self
        playerNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        playerNameJerseyField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupKeyboardToolbar()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupKeyboardToolbar() {
        // Create toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 44))
        toolbar.barStyle = .default
        
        // Flexible space and Done button
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [flexSpace, doneButton]
        toolbar.sizeToFit()
        
        // Assign to all text fields that need it
        playerNameField.inputAccessoryView = toolbar
        playerNameJerseyField.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    @IBAction func deletePlayerBtn(_ sender: Any) {
        delegate?.deletePlayer(cell: self)
    }
    
    func loadData(player: Player, rowIndex: Int) {
        playerNumberLabel.text = "Player \(rowIndex + 1)"
        index = rowIndex
        playerObj = player
        playerNameField.text = player.name
        if let jerseyN =  player.jerseyNumber {
            playerNameJerseyField.text = "\(jerseyN)"
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == playerNameField {
            playerObj.name = textField.text ?? ""
        } else {
            playerObj.jerseyNumber = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true ? nil : Int(textField.text ?? "")
        }
        delegate?.updateObject(cell: self)
    }
}
extension AddTeamCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
