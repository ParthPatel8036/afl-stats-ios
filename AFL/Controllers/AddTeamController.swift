//
//  AddTeamController.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import UIKit
protocol AddTeamControllerDelegate: AnyObject {
    func updateTeam(controller: AddTeamController, goBack: Bool)
}

class AddTeamController: UIViewController {
    
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var tableV: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var addAnotherBtn: UIButton!
    @IBOutlet weak var deleteTeamBtn: UIButton!
    
    
    var teamToEdit: Team?
    var newTeamObj: Team?
    let dbManager = DatabaseManager()
    weak var delegate: AddTeamControllerDelegate?
    var imageTappedFor = 0
    var teamPlayersArray = [Player]()
    var cellSelected: AddTeamCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialCode()
        setupKeyboardToolbar()
        // Do any additional setup after loading the view.
    }
    
    private func setupKeyboardToolbar() {
        // Create toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.barStyle = .default
        
        // Flexible space and Done button
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [flexSpace, doneButton]
        toolbar.sizeToFit()
        
        // Assign to all text fields that need it
        teamNameField.inputAccessoryView = toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Hide keyBoard by touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initialCode() {
        tableV.backgroundView = emptyView
        if teamToEdit != nil {
            self.title = "Update Team"
            confirmBtn.setTitle("Update", for: .normal)
            teamNameField.text = teamToEdit?.name
            teamPlayersArray = teamToEdit?.players ?? []
        }
    }
    
    func checkValidation() -> Bool {
        if (self.teamNameField.text?.isEmpty == true){
            showAlert(msg: "Team name is required")
            return false
        }
        if teamPlayersArray.count < 2 {
            showAlert(msg: "Minimum 2 players are required for making a Team")
            return false
        }
        for i in 0 ..< teamPlayersArray.count {
            if teamPlayersArray[i].name?.isEmpty == true {
                showAlert(msg: "Player \(i+1) name is required")
                return false
            } else if teamPlayersArray[i].jerseyNumber == nil {
                showAlert(msg: "Player \(i+1) jersey number is required")
                return false
            }
        }
        return true
    }
    
    
    func showAlert(msg: String) {
        var alert = UIAlertController()
        alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertController.Style.alert)
        let ok: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        addTeam(reset: false)
    }
    
    func showLoader() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LoaderController") as? LoaderController {
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }
    
    func addTeam(reset: Bool) {
        if(self.checkValidation() == false){
            return
        }
        showLoader()
        setObjects()
        if let obj = newTeamObj {
            addOrUpdateTeam(teamObj: obj, reset: reset)
        } else if let objEdit = teamToEdit {
            addOrUpdateTeam(teamObj: objEdit, reset: reset)
        }
    }
    
    func addOrUpdateTeam(teamObj: Team, reset: Bool) {
        showLoader()
        let dbManager = DatabaseManager()
        dbManager.addOrUpdateTeam(teamObject: teamObj, teamDocumentID: teamToEdit?.documentID){ [weak self] error in
            self?.hideLoader()
            if let _ = error {
                self?.showAlert(msg: "Something went wrong please Try again later")
            } else {
                if reset {
                    self?.showAlert(msg: "Team added")
                    self?.resetView()
                } else {
                    if let sel = self {
                        self?.delegate?.updateTeam(controller: sel, goBack: !reset)
                    }
                }
            }
        }
    }
    
    func resetView() {
        teamNameField.text = ""
        teamPlayersArray.removeAll()
        newTeamObj = nil
    }
    
    func setObjects() {
        let teamObj = Team(documentID: teamToEdit?.documentID ?? "0", name: teamNameField.text ?? "", players: teamPlayersArray)
        newTeamObj = teamObj
    }
    
    func deletePlayerAlert(playerObj: Player?) {
        weak var weakSelf = self
        var alertController = UIAlertController()
        alertController = UIAlertController(title: "Delete Player", message: "Are you sure you want to delete \(playerObj?.name ?? "")?", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
            weakSelf?.deletePlayer(playerObj: playerObj)
        }
        alertController.addAction(ok)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addPlayerBtn(_ sender: Any) {
        if teamPlayersArray.count == 18 {
            showAlert(msg: "A Team can contain only 18 players maximum")
        } else {
            teamPlayersArray.append(Player(documentID: "0", name: nil, jerseyNumber: nil, image: nil, imageURL: nil))
            tableV.reloadData()
        }
    }
    
    func deletePlayer(playerObj: Player?) {
        showLoader()
        dbManager.deletePlayer(teamId: teamToEdit?.documentID ?? "0", playerId: playerObj?.documentID ?? "") { [weak self] error in
            self?.hideLoader()
            if let error = error {
                print("error: \(error)")
                self?.showAlert(msg: "Something went wrong please Try again later")
            } else {
                if let index = self?.teamToEdit?.players.firstIndex(where: { $0.documentID == playerObj?.documentID }) {
                    self?.teamToEdit?.players.remove(at: index)
                    self?.teamPlayersArray = self?.teamToEdit?.players ?? []
                    self?.tableV.reloadData()
                    if let sel = self {
                        self?.delegate?.updateTeam(controller: sel, goBack: false)
                    }
                }
            }
        }
    }
    
    @IBAction func addMoreTeam(_ sender: Any) {
        addTeam(reset: true)
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension AddTeamController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if teamPlayersArray.isEmpty {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
        return teamPlayersArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: "AddTeamCell", for: indexPath) as! AddTeamCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.loadData(player: teamPlayersArray[indexPath.row], rowIndex: indexPath.row)
        return cell
    }
}
extension AddTeamController: AddTeamCellDelegate {
    func deletePlayer(cell: AddTeamCell) {
        if teamToEdit == nil {
            if teamPlayersArray.indices.contains(cell.index) {
                teamPlayersArray.remove(at: cell.index)
            }
        } else {
            deletePlayerAlert(playerObj: cell.playerObj)
        }
        tableV.reloadData()
    }
    
    func updateObject(cell: AddTeamCell) {
        if teamPlayersArray.indices.contains(cell.index) {
            teamPlayersArray[cell.index] = cell.playerObj
        }
    }
}
extension AddTeamController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
