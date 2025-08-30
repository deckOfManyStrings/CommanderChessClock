//
//  Models.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Player Model
struct Player {
    var life: Int = 40
    var elapsedTime: Double = 0.0
    var commanderDamage: [Int] = [0, 0, 0, 0] // Damage from each of 4 players (including self at index)
}

// MARK: - Display Mode for Life Total
enum LifeDisplayMode: Int, CaseIterable {
    case life = 0
    case commanderFromPlayer1 = 1
    case commanderFromPlayer2 = 2
    case commanderFromPlayer3 = 3
    
    func title(for playerIndex: Int) -> String {
        switch self {
        case .life:
            return "Life"
        case .commanderFromPlayer1:
            let otherPlayer = playerIndex == 0 ? 1 : 0
            return "⚔️ Player \(otherPlayer + 1)"
        case .commanderFromPlayer2:
            let otherPlayer = playerIndex <= 1 ? 2 : 1
            return "⚔️ Player \(otherPlayer + 1)"
        case .commanderFromPlayer3:
            let otherPlayer = playerIndex <= 2 ? 3 : 2
            return "⚔️ Player \(otherPlayer + 1)"
        }
    }
    
    func getOtherPlayerIndex(for currentPlayer: Int) -> Int {
        switch self {
        case .life:
            return -1 // Not applicable
        case .commanderFromPlayer1:
            return currentPlayer == 0 ? 1 : 0
        case .commanderFromPlayer2:
            return currentPlayer <= 1 ? 2 : 1
        case .commanderFromPlayer3:
            return currentPlayer <= 2 ? 3 : 2
        }
    }
}

// MARK: - Screen Manager Helper Class
class ScreenManager {
    func keepScreenAwake() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func allowScreenSleep() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
