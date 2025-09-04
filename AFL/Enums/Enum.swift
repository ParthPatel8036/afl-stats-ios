//
//  Enum.swift
//  AFL
//
//  Created by Part on 20/05/2025.
//

import Foundation

enum AFLActionType: String, CaseIterable {
    case kick       = "Kick"
    case handball   = "Handball"
    case mark       = "Mark"
    case tackle     = "Tackle"
    case goal       = "Goal"
    case behind     = "Behind"
    case freeKickFor     = "Free Kick For"
    case freeKickAgainst = "Free Kick Against"
    case hitOut     = "Hit-Out"
}
