//
//  GameState.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//

import SwiftUI
import Combine

// MARK: - Game State Management
class GameState: ObservableObject {
    @Published var players: [Player] = []
    @Published var activePlayerIndex: Int = 0
    @Published var priorityHeld: Bool = false
    @Published var priorityPlayerIndex: Int? = nil
    @Published var showingOptions: Bool = false
    @Published var colorScheme: ColorScheme = .light
    @Published var gameStarted: Bool = false
    @Published var isPaused: Bool = false
    @Published var clockEnabled: Bool = false
    
    // Call Time feature
    @Published var isTimingPlayer: Bool = false
    @Published var timedPlayerIndex: Int? = nil
    @Published var callTimeElapsed: Double = 0.0
    
    private var timer: Timer?
    private var callTimeTimer: Timer?
    private let totalPlayers = 4
    private var screenManager = ScreenManager()
    
    init() {
        setupPlayers()
    }
    
    private func setupPlayers() {
        players = (0..<totalPlayers).map { _ in Player() }
    }
    
    func startGame() {
        guard clockEnabled else { return }
        gameStarted = true
        isPaused = false
        screenManager.keepScreenAwake()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateTimer()
            }
        }
    }
    
    private func updateTimer() {
        guard !isPaused && clockEnabled else { return }
        
        if priorityHeld, let priorityIndex = priorityPlayerIndex {
            players[priorityIndex].elapsedTime += 0.1
        } else {
            players[activePlayerIndex].elapsedTime += 0.1
        }
    }
    
    // MARK: - Call Time Functions
    func startTimingPlayer(_ playerIndex: Int) {
        // Stop any existing timing first
        if isTimingPlayer {
            callTimeTimer?.invalidate()
            callTimeTimer = nil
        }
        
        isTimingPlayer = true
        timedPlayerIndex = playerIndex
        callTimeElapsed = 0.0
        
        screenManager.keepScreenAwake()
        
        callTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateCallTimer()
            }
        }
    }
    
    private func updateCallTimer() {
        callTimeElapsed += 0.1
    }
    
    func stopTimingPlayer() {
        callTimeTimer?.invalidate()
        callTimeTimer = nil
        
        isTimingPlayer = false
        timedPlayerIndex = nil
        callTimeElapsed = 0.0
        
        // Only allow sleep if main game isn't running
        if !gameStarted || clockEnabled == false {
            screenManager.allowScreenSleep()
        }
    }
    
    func resetCallTime() {
        callTimeElapsed = 0.0
    }
    
    func formattedCallTime() -> String {
        let minutes = Int(callTimeElapsed) / 60
        let seconds = Int(callTimeElapsed) % 60
        let centiseconds = Int((callTimeElapsed.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, centiseconds)
    }
    
    func togglePause() {
        guard clockEnabled else { return }
        isPaused.toggle()
        if isPaused {
            screenManager.allowScreenSleep()
        } else {
            screenManager.keepScreenAwake()
        }
    }
    
    func passTurn() {
        guard clockEnabled else { return }
        // Release priority when passing turn
        priorityHeld = false
        priorityPlayerIndex = nil
        
        // Move to next player (round robin)
        activePlayerIndex = (activePlayerIndex + 1) % totalPlayers
    }
    
    func togglePriority(for playerIndex: Int) {
        guard clockEnabled else { return }
        if priorityPlayerIndex == playerIndex {
            // Release priority
            priorityHeld = false
            priorityPlayerIndex = nil
        } else {
            // Hold priority
            priorityHeld = true
            priorityPlayerIndex = playerIndex
        }
    }
    
    func incrementLife(for playerIndex: Int) {
        players[playerIndex].life += 1
    }
    
    func decrementLife(for playerIndex: Int) {
        players[playerIndex].life = max(0, players[playerIndex].life - 1)
    }
    
    func formattedTime(for playerIndex: Int) -> String {
        guard clockEnabled else { return "00:00.0" }
        let elapsedTime = players[playerIndex].elapsedTime
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let centiseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, centiseconds)
    }
    
    func resetGame() {
        timer?.invalidate()
        callTimeTimer?.invalidate()
        
        setupPlayers()
        activePlayerIndex = 0
        priorityHeld = false
        priorityPlayerIndex = nil
        gameStarted = false
        isPaused = false
        isTimingPlayer = false
        timedPlayerIndex = nil
        callTimeElapsed = 0.0
        
        screenManager.allowScreenSleep()
    }
    
    deinit {
        timer?.invalidate()
        callTimeTimer?.invalidate()
        screenManager.allowScreenSleep()
    }
}
