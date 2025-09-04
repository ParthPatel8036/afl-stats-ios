//
//  FirestoreManager.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import FirebaseFirestore
import FirebaseStorage

class DatabaseManager {
    private let database = Firestore.firestore()
    
    func addOrUpdateTeam(teamObject: Team, teamDocumentID: String?, completion: @escaping (Error?) -> Void) {
        guard let teamName = teamObject.name else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Team name is missing"]))
            return
        }
        
        let teamData: [String: Any] = [
            "name": teamName
        ]
        
        var teamDocID: String
        
        if let documentID = teamDocumentID {
            // Update existing team
            teamDocID = documentID
        } else {
            // Create a new team document
            teamDocID = self.database.collection("teams").document().documentID
        }
        
        // Add or update the team document
        self.database.collection("teams").document(teamDocID).setData(teamData, merge: true) { error in
            if let error = error {
                completion(error)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            
            for player in teamObject.players {
                dispatchGroup.enter()
                var playerDocID: String
                
                if let docId = player.documentID, docId != "0" {
                    // Player exists, use the document ID provided
                    playerDocID = docId
                } else {
                    // Player does not exist, create a new document
                    playerDocID = self.database.collection("teams").document(teamDocID).collection("players").document().documentID
                }
                var playerData: [String: Any] = [
                    "name": player.name ?? "Player",
                    "jerseyNumber": player.jerseyNumber ?? 0
                ]
                // If no image provided, continue without uploading
                self.database.collection("teams").document(teamDocID).collection("players").document(playerDocID).setData(playerData, merge: true) { error in
                    if let error = error {
                        print("Error adding/updating player to Firestore: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        completion(error)
                        return
                    }
                    dispatchGroup.leave()
                }
                
            }
            
            // Notify when all player data is added/updated
            dispatchGroup.notify(queue: .main) {
                completion(nil)
            }
        }
    }
    
    
    func fetchAllTeams(completion: @escaping ([Team]?, Error?) -> Void) {
        database.collection("teams").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let teamDocuments = querySnapshot?.documents, !teamDocuments.isEmpty else {
                completion([], nil)
                return
            }
            
            var teams = [Team]()
            let dispatchGroup = DispatchGroup()
            
            for document in teamDocuments {
                dispatchGroup.enter()
                let data = document.data()
                var team = Team(documentID: document.documentID, name: data["name"] as? String ?? "Team", players: [])
                
                self.database.collection("teams").document(document.documentID).collection("players").getDocuments { (playerSnapshot, error) in
                    if let error = error {
                        dispatchGroup.leave()
                        completion(nil, error)
                        return
                    }
                    
                    var playersWithImages = [(Player, UIImage?)]()
                    
                    for playerDocument in playerSnapshot?.documents ?? [] {
                        let playerData = playerDocument.data()
                        let player = Player(
                            documentID: playerDocument.documentID,
                            name: playerData["name"] as? String,
                            jerseyNumber: playerData["jerseyNumber"] as? Int,
                            image: nil,
                            imageURL: playerData["imageURL"] as? String
                        )
                        playersWithImages.append((player, nil))
                    }
                    
                    team.players = playersWithImages.map { $0.0 }
                    teams.append(team)
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(teams, nil)
            }
        }
    }
    
    func deleteTeam(teamId: String, completion: @escaping (Error?) -> Void) {
        let teamReference = database.collection("teams").document(teamId)
        teamReference.delete { error in
            completion(error)
        }
    }
    
    func deletePlayer(teamId: String, playerId: String, completion: @escaping (Error?) -> Void) {
        let playerReference = database.collection("teams").document(teamId).collection("players").document(playerId)
        
        playerReference.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let _ = document else {
                let deleteError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Player document not found"])
                completion(deleteError)
                return
            }
            
            playerReference.delete { error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func fetchAllMatches(completion: @escaping ([Match]?, Error?) -> Void) {
        database.collection("matches")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    var matches: [Match] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let match = Match(
                            documentID: document.documentID,
                            team1: data["team1"] as? String ?? "",
                            team2: data["team2"] as? String ?? "",
                            team1Doc: data["team1Doc"] as? String ?? "",
                            team2Doc: data["team2Doc"] as? String ?? "",
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            team1Goals: data["team1Goals"] as? Int ?? 0,
                            team1Behinds: data["team1Behinds"] as? Int ?? 0,
                            team2Goals: data["team2Goals"] as? Int ?? 0,
                            team2Behinds: data["team2Behinds"] as? Int ?? 0,
                            currentQuarter: data["currentQuarter"] as? Int ?? 1,
                            timeRemaining: data["timeRemaining"] as? String ?? "20:00",
                            playerStats: [:]
                        )
                        matches.append(match)
                    }
                    completion(matches, nil)
                }
            }
    }
    
    func addMatch(match: Match, completion: @escaping (String?, Error?) -> Void) {
        let matchData: [String: Any] = [
            "team1": match.team1,
            "team2": match.team2,
            "team1Doc": match.team1Doc,
            "team2Doc": match.team2Doc,
            "date": Timestamp(date: match.date)
        ]
        var documentRef: DocumentReference? = nil
        documentRef = database.collection("matches").addDocument(data: matchData) { error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(documentRef?.documentID ?? nil, nil)
            }
        }
    }
    
    func updateMatch(matchId: String, match: Match, completion: @escaping (Error?) -> Void) {
        let matchRef = database.collection("matches").document(matchId)
        
        // 1) Serialize AFLPlayerStats to dictionaries
        let statsDict: [String: Any] = match.playerStats.reduce(into: [String: Any]()) { dict, pair in
            let (playerID, stats) = pair
            dict[playerID] = [
                "kicks": stats.kicks,
                "handballs": stats.handballs,
                "marks": stats.marks,
                "tackles": stats.tackles,
                "goals": stats.goals,
                "behinds": stats.behinds,
                "hitOuts": stats.hitOuts,
                "freeKicksFor": stats.freeKicksFor,
                "freeKicksAgainst": stats.freeKicksAgainst
            ]
        }
        
        // 2) Build the Firestore data dictionary
        let matchData: [String: Any] = [
            "team1":           match.team1,
            "team2":           match.team2,
            "team1Doc":        match.team1Doc,
            "team2Doc":        match.team2Doc,
            "date":            Timestamp(date: match.date),
            
            // AFL score breakdown
            "team1Goals":      match.team1Goals,
            "team1Behinds":    match.team1Behinds,
            "team2Goals":      match.team2Goals,
            "team2Behinds":    match.team2Behinds,
            
            // Game clock
            "currentQuarter":  match.currentQuarter,
            "timeRemaining":   match.timeRemaining,
            
            // Nested player stats
            "playerStats":     statsDict
        ]
        
        // 3) Write to Firestore
        matchRef.updateData(matchData) { error in
            completion(error)
        }
    }
    
}
