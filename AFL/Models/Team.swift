//
//  Team.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import Foundation

struct Team {
    var documentID: String?
    var name: String?
    var players: [Player]
    
    // Initializer without documentID for adding new teams
    init(name: String, players: [Player]) {
        self.name = name
        self.players = players
        self.documentID = nil
    }
    
    // Initializer with documentID for fetching existing teams
    init(documentID: String, name: String, players: [Player]) {
        self.documentID = documentID
        self.name = name
        self.players = players
    }
}
