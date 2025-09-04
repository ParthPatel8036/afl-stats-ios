//
//  HomeController.swift
//  AFL
//
//  Created by Parth on 21/05/2025.
//

import UIKit

class HomeController: UIViewController {
    
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    let refreshControl = UIRefreshControl()
    var matchesArray = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad()
        // Do any additional setup after loading the view.
    }
    
    func initialLoad() {
        matchesTableView.delegate = self
        matchesTableView.dataSource = self
        matchesTableView.backgroundView = emptyView
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMatchesData(showLoader: true)
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.55, green: 0.44, blue: 0.32, alpha: 1.00),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: .medium)] as [NSAttributedString.Key : Any]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        matchesTableView.refreshControl = refreshControl
    }
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
        fetchMatchesData(showLoader: false)
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
    
    func fetchMatchesData(showLoader: Bool) {
        let dbManager = DatabaseManager()
        if showLoader {
            self.showLoader()
        }
        dbManager.fetchAllMatches { [weak self] (matches, error) in
            self?.hideLoader()
            self?.refreshControl.endRefreshing()
            if let error = error {
                // Show error message
                print("Error fetching teams: \(error.localizedDescription)")
            } else {
                self?.matchesArray = matches ?? []
                self?.matchesTableView.reloadData()
            }
        }
    }
}
extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if matchesArray.isEmpty {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
        return matchesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchesTableView.dequeueReusableCell(withIdentifier: "MatchesCell", for: indexPath) as! MatchesCell
        
        cell.selectionStyle = .none
        cell.loadMatch(match: matchesArray[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
