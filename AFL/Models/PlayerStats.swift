//
//  PlayerStats.swift
//  AFL
//
//  Created by Parth on 21/05/2025.
//

import Foundation

struct AFLPlayerStats {
    var kicks: Int = 0
    var handballs: Int = 0
    var disposals: Int { kicks + handballs }
    var marks: Int = 0
    var tackles: Int = 0
    var goals: Int = 0
    var behinds: Int = 0
    var hitOuts: Int = 0
    var freeKicksFor: Int = 0
    var freeKicksAgainst: Int = 0
}
