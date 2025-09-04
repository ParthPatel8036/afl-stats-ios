//
//  Match.swift
//  AFL
//
//  Created by Parth on 21/05/2025.
//

import Foundation

struct Match {
    var documentID: String?
    var team1: String
    var team2: String
    var team1Doc: String
    var team2Doc: String
    var date: Date
    var team1Obj: Team?
    var team2Obj: Team?
    
    // AFL-specific scores
    var team1Goals: Int
    var team1Behinds: Int
    var team2Goals: Int
    var team2Behinds: Int
    var team1Score: Int { team1Goals * 6 + team1Behinds }
    var team2Score: Int { team2Goals * 6 + team2Behinds }
    // Game clock
    var currentQuarter: Int       // 1–4 (or extra time)
    var timeRemaining: String     // e.g. "10:34"
    
    // Stats per player (keyed by player.documentID)
    var playerStats: [String: AFLPlayerStats]
    
    // MARK: — New match (no docID yet)
    init(team1: String,
         team2: String,
         team1Doc: String,
         team2Doc: String,
         date: Date,
         team1Obj: Team? = nil,
         team2Obj: Team? = nil,
         team1Goals: Int = 0,
         team1Behinds: Int = 0,
         team2Goals: Int = 0,
         team2Behinds: Int = 0,
         currentQuarter: Int = 1,
         timeRemaining: String = "20:00",
         playerStats: [String: AFLPlayerStats] = [:])
    {
        self.documentID       = nil
        self.team1            = team1
        self.team2            = team2
        self.team1Doc         = team1Doc
        self.team2Doc         = team2Doc
        self.date             = date
        self.team1Obj         = team1Obj
        self.team2Obj         = team2Obj
        self.team1Goals       = team1Goals
        self.team1Behinds     = team1Behinds
        self.team2Goals       = team2Goals
        self.team2Behinds     = team2Behinds
        self.currentQuarter   = currentQuarter
        self.timeRemaining    = timeRemaining
        self.playerStats      = playerStats
    }
    
    // MARK: — Fetched match
    init(documentID: String,
         team1: String,
         team2: String,
         team1Doc: String,
         team2Doc: String,
         date: Date,
         team1Obj: Team? = nil,
         team2Obj: Team? = nil,
         team1Goals: Int = 0,
         team1Behinds: Int = 0,
         team2Goals: Int = 0,
         team2Behinds: Int = 0,
         currentQuarter: Int = 1,
         timeRemaining: String = "20:00",
         playerStats: [String: AFLPlayerStats] = [:])
    {
        self.documentID       = documentID
        self.team1            = team1
        self.team2            = team2
        self.team1Doc         = team1Doc
        self.team2Doc         = team2Doc
        self.date             = date
        self.team1Obj         = team1Obj
        self.team2Obj         = team2Obj
        self.team1Goals       = team1Goals
        self.team1Behinds     = team1Behinds
        self.team2Goals       = team2Goals
        self.team2Behinds     = team2Behinds
        self.currentQuarter   = currentQuarter
        self.timeRemaining    = timeRemaining
        self.playerStats      = playerStats
    }
}
