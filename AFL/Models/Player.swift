//
//  Player.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import Foundation
import UIKit

struct Player {
    var documentID: String?
    var name: String?
    var jerseyNumber: Int?
    
    // Empty initializer
    init() {
        self.documentID = nil
        self.name = nil
        self.jerseyNumber = nil
    }
    
    // Initializer for player data fetched from Firestore (with document ID)
    init(documentID: String, name: String?, jerseyNumber: Int?, image: UIImage?, imageURL: String?) {
        self.documentID = documentID
        self.name = name
        self.jerseyNumber = jerseyNumber
    }
    
    // Initializer for new player data created locally (without document ID)
    init(name: String?, jerseyNumber: Int?, image: UIImage?, imageURL: String?) {
        self.documentID = nil
        self.name = name
        self.jerseyNumber = jerseyNumber
    }
}

