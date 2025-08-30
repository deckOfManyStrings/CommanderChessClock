//
//  PlayerQuadrantView.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//

import SwiftUI

struct PlayerQuadrantView: View {
    let playerIndex: Int
    @ObservedObject var gameState: GameState
    let isActive: Bool
    @State private var showingPlayerOptions = false
    
    var body: some View {
        ZStack {
            // Background color based on active state and theme
            let backgroundColor = isActive ? Color.green.opacity(0.3) :
                                 (gameState.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            let borderColor = isActive ? Color.green :
                             (gameState.colorScheme == .dark ? Color.gray : Color.gray.opacity(0.5))
            let textColor = gameState.colorScheme == .dark ? Color.white : Color.black
            
            // Special styling if this player is being timed
            let isBeingTimed = gameState.timedPlayerIndex == playerIndex && gameState.isTimingPlayer
            let finalBackgroundColor = isBeingTimed ? Color.red.opacity(0.3) : backgroundColor
            let finalBorderColor = isBeingTimed ? Color.red : borderColor
            
            RoundedRectangle(cornerRadius: 8)
                .fill(finalBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(finalBorderColor, lineWidth: isBeingTimed ? 3 : 2)
                )
            
            VStack(spacing: 16) {
                // Row 1: Player number and display mode indicator
                HStack {
                    Text("P\(playerIndex + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(textColor.opacity(0.8))
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(textColor.opacity(0.5))
                    
                    Text(gameState.getDisplayTitle(for: playerIndex))
                        .font(.caption)
                        .foregroundColor(textColor.opacity(0.7))
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                
                // Row 2: Main life/commander damage controls
                HStack(spacing: 24) {
                    Button("-") {
                        gameState.decrementDisplayedValue(for: playerIndex)
                    }
                    .buttonStyle(LargeLifeButtonStyle(colorScheme: gameState.colorScheme))
                    
                    // Tappable life/commander damage total that cycles display modes
                    Button(action: {
                        gameState.cycleDisplayMode(for: playerIndex)
                    }) {
                        Text("\(gameState.getDisplayedValue(for: playerIndex))")
                            .applyLifeFont()
                            .foregroundColor(textColor)
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(PlainButtonStyle()) // Remove default button styling
                    
                    Button("+") {
                        gameState.incrementDisplayedValue(for: playerIndex)
                    }
                    .buttonStyle(LargeLifeButtonStyle(colorScheme: gameState.colorScheme))
                }
                
                // Row 3: Secondary info, timer (if enabled), priority button (if clock enabled), and options button
                HStack {
                    // Current life total (when not in life mode)
                    if gameState.playerDisplayModes[playerIndex] != .life {
                        Text("Life: \(gameState.players[playerIndex].life)")
                            .font(.caption)
                            .foregroundColor(textColor.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Timer (only show if clock is enabled)
                    if gameState.clockEnabled {
                        Text(gameState.formattedTime(for: playerIndex))
                            .applyTimerFont()
                            .foregroundColor(textColor)
                    }
                    
                    // Priority button (only show if clock is enabled)
                    if gameState.clockEnabled {
                        Button(gameState.priorityPlayerIndex == playerIndex ? "Release" : "Priority") {
                            gameState.togglePriority(for: playerIndex)
                        }
                        .buttonStyle(CompactPriorityButtonStyle(isHolding: gameState.priorityPlayerIndex == playerIndex))
                    }
                    
                    Button(action: {
                        showingPlayerOptions = true
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(textColor.opacity(0.7))
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(12)
        }
        .sheet(isPresented: $showingPlayerOptions) {
            PlayerOptionsView(
                playerIndex: playerIndex,
                gameState: gameState,
                isPresented: $showingPlayerOptions
            )
        }
    }
}

// MARK: - Player Options View
struct PlayerOptionsView: View {
    let playerIndex: Int
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Player \(playerIndex + 1) Options")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 20) {
                    // Call Time Section
                    VStack(spacing: 12) {
                        Text("Judge Timer")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if gameState.isTimingPlayer && gameState.timedPlayerIndex == playerIndex {
                            VStack(spacing: 8) {
                                Text("TIMING IN PROGRESS")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                
                                Text(gameState.formattedCallTime())
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(.red)
                                
                                HStack(spacing: 16) {
                                    Button("Stop Timer") {
                                        gameState.stopTimingPlayer()
                                    }
                                    .buttonStyle(StopTimingButtonStyle())
                                    
                                    Button("Reset Timer") {
                                        gameState.resetCallTime()
                                    }
                                    .buttonStyle(ResetTimingButtonStyle())
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            Button("Start Call Time") {
                                gameState.startTimingPlayer(playerIndex)
                                isPresented = false // Close modal when starting timer
                            }
                            .buttonStyle(StartCallTimeButtonStyle())
                            .disabled(gameState.isTimingPlayer && gameState.timedPlayerIndex != playerIndex)
                            
                            Text("Track how long this player takes for decisions. Used by judges to monitor slow play.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                Spacer()
                
                Button("Close") {
                    isPresented = false
                }
                .buttonStyle(PassTurnButtonStyle())
                .padding(.bottom)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct CompactPriorityButtonStyle: ButtonStyle {
    let isHolding: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isHolding ? Color.red : Color.orange)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

// MARK: - Clean Borderless Life Button Style
struct LargeLifeButtonStyle: ButtonStyle {
    let colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .frame(width: 70, height: 70)
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .applyButtonAnimation(configuration.isPressed)
    }
}

// MARK: - Additional Button Styles
struct StartCallTimeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.blue)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct PriorityToggleButtonStyle: ButtonStyle {
    let isHolding: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isHolding ? Color.red : Color.orange)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}
