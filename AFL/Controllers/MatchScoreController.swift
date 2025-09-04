//
//  MatchScoreController.swift
//  AFL
//
//  Created by Parth on 25/05/2025.
//


import UIKit

class MatchScoreController: UIViewController {
    
    // MARK: — IBOutlets
    @IBOutlet weak var scoreLabel:       UILabel!
    @IBOutlet weak var eventsCollection: UICollectionView!
    @IBOutlet weak var statsTableView:   UITableView!
    
    // MARK: — State
    var currentMatch: Match!
    var allEvents: [String] = []
    let actions = AFLActionType.allCases
    // Cell padding constants
    private let cellHorizontalPadding: CGFloat = 16
    private let cellVerticalPadding: CGFloat = 8
    var team1Players: [Player] = []
    var team2Players: [Player] = []
    var scoreSection1: [ScoreCard] = []
    var scoreSection2: [ScoreCard] = []
    
    private var selectedPlayer: Player?
    
    // Picker
    // MARK: - Picker Management
    private lazy var pickerContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        container.layer.shadowOpacity = 0.2
        container.layer.shadowRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var pickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private var pickerBottomConstraint: NSLayoutConstraint?
    private var toolbar = UIToolbar()
    private var isPickerShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // register, delegate, datasource, etc.
        eventsCollection.delegate = self
        eventsCollection.dataSource = self
        statsTableView.delegate = self
        statsTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(matchUpdated),
                                               name: Notifications.UpdateMatch,
                                               object: nil)
    }
    
    private func setupPicker() {
        // Add container to view hierarchy
        view.addSubview(pickerContainer)
        
        // Add toolbar and picker to container
        pickerContainer.addSubview(pickerToolbar)
        pickerContainer.addSubview(picker)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            pickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pickerToolbar.topAnchor.constraint(equalTo: pickerContainer.topAnchor),
            pickerToolbar.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor),
            pickerToolbar.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor),
            pickerToolbar.heightAnchor.constraint(equalToConstant: 44),
            
            picker.topAnchor.constraint(equalTo: pickerToolbar.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: pickerContainer.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: 216)
        ])
        
        // Store bottom constraint for animation
        pickerBottomConstraint = pickerContainer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 300
        )
        pickerBottomConstraint?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func matchUpdated() {
        loadTeamsAndStats()
    }
    
    private func loadTeamsAndStats() {
        // Assign team1/2 players
        if currentMatch != nil && currentMatch.team1Obj != nil && currentMatch.team2Obj != nil {
            team1Players = currentMatch.team1Obj?.players ?? []
            team2Players = currentMatch.team2Obj?.players ?? []
            rebuildScoreSections()
            updateScoreLabel()
            statsTableView.reloadData()
            eventsCollection.reloadData()
        } else {
            var alert = UIAlertController()
            alert = UIAlertController(title: "Alert", message: "No live Match. Start match first", preferredStyle: UIAlertController.Style.alert)
            let ok: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                self.tabBarController?.selectedIndex = 1
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updateScoreLabel() {
        let t1 = currentMatch.team1Obj?.name ?? ""
        let t2 = currentMatch.team2Obj?.name ?? ""
        let g1 = currentMatch.team1Score
        let b1 = currentMatch.team1Behinds
        let g2 = currentMatch.team2Score
        let b2 = currentMatch.team2Behinds
        // AFL notation: goals.behinds (points)
        let p1 = g1 * 6 + b1
        let p2 = g2 * 6 + b2
        scoreLabel.text = "\(t1)  \(g1).\(b1) (\(p1))  —  \(t2)  \(g2).\(b2) (\(p2))"
    }
    
    private func rebuildScoreSections() {
        scoreSection1 = team1Players.map {
            ScoreCard(name: $0.name ?? "", stats: currentMatch.playerStats[$0.documentID ?? ""] ?? AFLPlayerStats())
        }
        scoreSection2 = team2Players.map {
            ScoreCard(name: $0.name ?? "", stats: currentMatch.playerStats[$0.documentID ?? ""] ?? AFLPlayerStats())
        }
    }
    
    // MARK: - Show/Hide Picker
    private func showPicker() {
        guard selectedPlayer != nil else {
            //            showAlert(title: "Select Player", message: "Please tap a player first")
            return
        }
        
        // Prevent multiple pickers
        if pickerContainer.superview == nil {
            setupPicker()
        }
        
        // Reset picker selection
        picker.selectRow(0, inComponent: 0, animated: false)
        
        // Animate in
        pickerBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func hidePicker() {
        pickerBottomConstraint?.constant = 300
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.pickerContainer.removeFromSuperview()
        })
    }
    
    // MARK: - Picker Actions
    @objc private func donePicker() {
        let selectedAction = AFLActionType.allCases[picker.selectedRow(inComponent: 0)]
        apply(action: selectedAction)
        hidePicker()
    }
    
    @objc private func cancelPicker() {
        hidePicker()
    }
    
    private func dismissPicker() {
        // animate out & remove subviews...
        picker.removeFromSuperview()
        toolbar.removeFromSuperview()
        isPickerShowing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentMatch == nil {
            self.view.isUserInteractionEnabled = false
            var alert = UIAlertController()
            alert = UIAlertController(title: "Alert", message: "No live Match. Start match first", preferredStyle: UIAlertController.Style.alert)
            let ok: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                self.tabBarController?.selectedIndex = 1
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else{
            self.view.isUserInteractionEnabled = true
            loadTeamsAndStats()
        }
    }
    
    // 5) Apply the selected AFL action:
    private func apply(action: AFLActionType) {
        guard let player = selectedPlayer,
              let pid = player.documentID else { return }
        
        // Ensure stats exist
        if currentMatch.playerStats[pid] == nil {
            currentMatch.playerStats[pid] = AFLPlayerStats()
        }
        if var stats = currentMatch.playerStats[pid] {
            
            // Increment
            switch action {
            case .kick:          stats.kicks += 1
            case .handball:      stats.handballs += 1
            case .mark:          stats.marks += 1
            case .tackle:        stats.tackles += 1
            case .goal:
                stats.goals += 1
                if playerIsOnTeam1(player) {
                    currentMatch.team1Goals += 1    // ← correct stored property
                } else {
                    currentMatch.team2Goals += 1
                }
                
            case .behind:
                stats.behinds += 1
                if playerIsOnTeam1(player) {
                    currentMatch.team1Behinds += 1
                } else {
                    currentMatch.team2Behinds += 1
                }
            case .freeKickFor:     stats.freeKicksFor += 1
            case .freeKickAgainst: stats.freeKicksAgainst += 1
            case .hitOut:         stats.hitOuts += 1
            }
            
            // Save back
            currentMatch.playerStats[pid] = stats
            
            // Log event & refresh UI
            allEvents.append("\(player.name ?? ""): \(action.rawValue)")
            rebuildScoreSections()
            updateScoreLabel()
            eventsCollection.reloadData()
            statsTableView.reloadData()
        }
    }
    
    private func playerIsOnTeam1(_ p: Player) -> Bool {
        return team1Players.contains { $0.documentID == p.documentID }
    }
    
    
    @IBAction func endMatchBtn(_ sender: Any) {
        showEndMatchConfirmationAlert()
    }
    
    func showEndMatchConfirmationAlert() {
        let alert = UIAlertController(
            title: "End Match",
            message: "Are you sure you want to end the match?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let endMatchAction = UIAlertAction(title: "End Match", style: .destructive) { _ in
            self.resetView()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(endMatchAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func resetView() {
        allEvents.removeAll()
        scoreSection1.removeAll()
        scoreSection2.removeAll()
        self.scoreLabel.text = "Team A 0.0 (0) — Team B 0.0 (0)"
        eventsCollection.reloadData()
        tabBarController?.selectedIndex = 1
        currentMatch.documentID = nil
        currentMatch = nil
        statsTableView.reloadData()
    }
}

// MARK: - UICollectionView for events
extension MatchScoreController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "EventCell", for: ip) as! EventCell
        cell.eventLabel.text = allEvents[ip.row]
        cell.eventLabel.textColor = .white
        cell.eventView.layer.cornerRadius = 12
        cell.eventView.backgroundColor = UIColor.brown.withAlphaComponent(0.8)
        return cell
    }
    
    // Dynamic width based on text content
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = allEvents[indexPath.row]
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = text
        label.sizeToFit()
        
        return CGSize(
            width: label.frame.width + (cellHorizontalPadding * 2),
            height: 40 // Fixed height
        )
    }
    
    // Handle cell selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventText = allEvents[indexPath.row]
        
        // Visual feedback
        if let cell = collectionView.cellForItem(at: indexPath) as? EventCell {
            UIView.animate(withDuration: 0.2, animations: {
                cell.eventView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                cell.eventView.backgroundColor = UIColor.systemBlue.withAlphaComponent(1.0)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    cell.eventView.transform = .identity
                    cell.eventView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
                }
            }
        }
        
        // Show alert with event details
        showEventAlert(event: eventText)
    }
    
    private func showEventAlert(event: String) {
        let alert = UIAlertController(
            title: "Match Event",
            message: event,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        // Present with haptic feedback
        present(alert, animated: true) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    // Spacing and insets configuration
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

// MARK: — UITableView for player stats
extension MatchScoreController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tv: UITableView) -> Int {
        2
    }
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? scoreSection1.count + 1 : scoreSection2.count + 1
    }
    
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let isTeam1 = ip.section == 0
        if ip.row == 0 {
            let cell = tv.dequeueReusableCell(withIdentifier: "SectionHeaderCell", for: ip) as! SectionHeaderCell
            cell.setUpForAFLStats()
            return cell
        } else {
            let card = (isTeam1 ? scoreSection1 : scoreSection2)[ip.row - 1]
            let cell = tv.dequeueReusableCell(withIdentifier: "SectionHeaderCell", for: ip) as! SectionHeaderCell
            cell.loadAFLStats(stats: card.stats, playerName: card.name)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if currentMatch != nil {
            if section == 0 {
                return currentMatch.team1.capitalized
            } else {
                return currentMatch.team2.capitalized
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        guard ip.row > 0 else { return }
        // pick the tapped player
        let player = (ip.section == 0 ? team1Players : team2Players)[ip.row - 1]
        selectedPlayer = player
        showPicker()
    }
}

// MARK: — UIPicker for selecting action
extension MatchScoreController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pv: UIPickerView) -> Int { 1 }
    func pickerView(_ pv: UIPickerView, numberOfRowsInComponent c: Int) -> Int {
        return actions.count
    }
    func pickerView(_ pv: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return actions[row].rawValue
    }
}
