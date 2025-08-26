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
