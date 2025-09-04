//
//  TeamsController.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import UIKit

class TeamsController: UIViewController {
    
    @IBOutlet weak var teamsTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    let refreshControl = UIRefreshControl()
    var teamsArray = [Team]()
    var openedIndexes = [Int]()
    var selectedTeams = [Team]()
    var battingTeam: Team?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTeamsData(showLoader: false)
    }
    
    func initialLoad() {
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
        fetchTeamsData(showLoader: true)
        teamsTableView.backgroundView = emptyView
        addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: .medium)] as [NSAttributedString.Key : Any]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        teamsTableView.refreshControl = refreshControl
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        fetchTeamsData(showLoader: false)
    }
    
    func showLoader() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LoaderController") as? LoaderController {
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        }
    }
    
    func hideLoader() {
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            weakSelf?.dismiss(animated: true)
        }
    }
    
    func fetchTeamsData(showLoader: Bool) {
        if showLoader {
            self.showLoader()
        }
        let dbManager = DatabaseManager()
        dbManager.fetchAllTeams { [weak self] (teams, error) in
            self?.hideLoader()
            self?.refreshControl.endRefreshing()
            if let error = error {
                // Show error message
                print("Error fetching teams: \(error.localizedDescription)")
            } else {
                self?.teamsArray = teams ?? []
                self?.teamsTableView.reloadData()
            }
        }
    }
    
    @IBAction func addTeamBtn(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddTeamController") as? AddTeamController {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func startMatchBtn(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.afMatch != nil {
            showAlert(msg: "A match is ongoing please end that first.")
            tabBarController?.selectedIndex = 3
            
        } else if selectedTeams.isEmpty {
            showAlert(msg: "Select 2 Teams to start match")
        } else if selectedTeams.count == 2 {
            if selectedTeams[0].players.count != selectedTeams[1].players.count {
                showAlert(msg: "Select 2 Teams which have same number of players")
            } else {
                selectStartTeam()
            }
        } else {
            selectStartTeam()
        }
    }
    
    func selectStartTeam() {
        weak var weakSelf = self
        var alertController = UIAlertController()
        alertController = UIAlertController(title: "Start", message: "Which team will kick off first?", preferredStyle: .alert)
        let first = UIAlertAction(title: "\(selectedTeams.first?.name ?? "")", style: .default) { (action) -> Void in
            weakSelf?.battingTeam = weakSelf?.selectedTeams.first
            weakSelf?.startMatch()
        }
        alertController.addAction(first)
        let sec = UIAlertAction(title: "\(selectedTeams[1].name ?? "")", style: .default) { (action) -> Void in
            weakSelf?.battingTeam = weakSelf?.selectedTeams[1]
            weakSelf?.startMatch()
        }
        alertController.addAction(sec)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func startMatch() {
        var team1Obj: Team?
        var team2Obj: Team?
        let dbManager = DatabaseManager()
        
        team1Obj = selectedTeams.first
        if selectedTeams.indices.contains(1) {
            team2Obj = selectedTeams[1]
        }
        
        var match = Match(
            team1: team1Obj?.name ?? "Team A",
            team2: team2Obj?.name ?? "Team B",
            team1Doc: team1Obj?.documentID ?? "0",
            team2Doc: team2Obj?.documentID ?? "0",
            date: Date(),
            team1Obj: team1Obj,
            team2Obj: team2Obj
        )
        
        showLoader()
        dbManager.addMatch(match: match) { [weak self] docId, error in
            self?.hideLoader()
            if let error = error {
                print("Error adding match: \(error.localizedDescription)")
                self?.showAlert(msg: "Something went wrong. Try again later.")
            } else {
                match.documentID = docId
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.afMatch = match
                }
                self?.matchAdded(match: match)
                print("Match added successfully")
            }
        }
    }
    
    
    func matchAdded(match: Match) {
        var mat = match
        weak var weakSelf = self
        var alertController = UIAlertController()
        alertController = UIAlertController(title: "Success", message: "Match added", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: .destructive) { (action) -> Void in
            NotificationCenter.default.post(name: Notifications.UpdateMatch, object: nil)
            if let nav = weakSelf?.tabBarController?.viewControllers?[3] as? UINavigationController {
                let matchVC = nav.viewControllers.first as? MatchScoreController
                matchVC?.currentMatch = mat
            }
            weakSelf?.tabBarController?.selectedIndex = 3
            weakSelf?.resetView()
        }
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resetView() {
        selectedTeams.removeAll()
        teamsTableView.reloadData()
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
}
extension TeamsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if teamsArray.isEmpty {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
        return teamsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if openedIndexes.contains(section) {
            return teamsArray[section].players.count + 2
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = teamsTableView.dequeueReusableCell(withIdentifier: "TeamsCell", for: indexPath) as! TeamsCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.setTeamData(obj: teamsArray[indexPath.section], selectedT: selectedTeams)
            cell.deleteBtn.alpha = 1
            return cell
        } else if indexPath.row == 1 {
            let cell = teamsTableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = teamsTableView.dequeueReusableCell(withIdentifier: "TeamsCell", for: indexPath) as! TeamsCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.setPlayersData(obj: teamsArray[indexPath.section].players[indexPath.row - 2], teamObj: teamsArray[indexPath.section])
            cell.deleteBtn.alpha = 0
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let index = openedIndexes.firstIndex(where: {$0 == indexPath.section}) {
                openedIndexes.remove(at: index)
            } else {
                openedIndexes.append(indexPath.section)
            }
            teamsTableView.reloadData()
        }
    }
    
    func deleteTeamAlert(teamObj: Team?) {
        weak var weakSelf = self
        var alertController = UIAlertController()
        alertController = UIAlertController(title: "Delete Team", message: "Are you sure you want to delete \(teamObj?.name ?? "")?", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
            weakSelf?.deleteTeam(team: teamObj)
        }
        alertController.addAction(ok)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteTeam(team: Team?){
        let dbManager = DatabaseManager()
        showLoader()
        dbManager.deleteTeam(teamId: team?.documentID ?? "") { [weak self] error in
            self?.hideLoader()
            if let error = error {
                // Show error message
                print("Error deleting team: \(error.localizedDescription)")
                self?.showAlert(msg: "Something went wrong please Try again later")
            } else {
                // Remove the deleted team from the local data model and reload the table view
                if let index = self?.teamsArray.firstIndex(where: { $0.documentID == team?.documentID }) {
                    self?.teamsArray.remove(at: index)
                    self?.teamsTableView.reloadData()
                }
            }
        }
    }
}
extension TeamsController: TeamsCellDelegate {
    func checkBoxTapped(teamObj: Team?) {
        if let index = selectedTeams.firstIndex(where: {$0.documentID == teamObj?.documentID}) {
            selectedTeams.remove(at: index)
            teamsTableView.reloadData()
        } else {
            if let obj = teamObj {
                if selectedTeams.count < 2 {
                    selectedTeams.append(obj)
                    teamsTableView.reloadData()
                } else {
                    showAlert(msg: "Cannot select more then 2 Teams for a match.")
                }
            }
        }
    }
    
    func deleteTapped(teamObj: Team?) {
        if teamObj != nil {
            deleteTeamAlert(teamObj: teamObj)
        } else {
            goToEdit(obj: teamObj)
        }
    }
    
    func goToEdit(obj: Team?) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddTeamController") as? AddTeamController {
            vc.teamToEdit = obj
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func editTapped(teamObj: Team?) {
        goToEdit(obj: teamObj)
    }
}
extension TeamsController: AddTeamControllerDelegate {
    func updateTeam(controller: AddTeamController, goBack: Bool) {
        if goBack {
            controller.navigationController?.popViewController(animated: true)
        }
        self.fetchTeamsData(showLoader: true)
    }
}
