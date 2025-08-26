//
//  OptionsView.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//


import SwiftUI

struct OptionsView: View {
    @ObservedObject var gameState: GameState
    @Binding var isPresented: Bool
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Game Options")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Clock Settings Section
                    VStack(spacing: 16) {
                        Text("Clock Settings")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Toggle(isOn: $gameState.clockEnabled) {
                            HStack {
                                Image(systemName: gameState.clockEnabled ? "clock.fill" : "clock")
                                    .foregroundColor(gameState.clockEnabled ? .blue : .gray)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Enable Clock")
                                        .font(.body)
                                    Text(gameState.clockEnabled ? "Timers and turn management active" : "Life counter only mode")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.horizontal, 4)
                        
                        // Show warning if clock is disabled during active game
                        if !gameState.clockEnabled && gameState.gameStarted {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Clock disabled during active game. Timer will pause.")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Call Time explanation
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "stopwatch")
                                    .foregroundColor(.blue)
                                Text("Call Time Feature")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            Text("Use 'Call Time' buttons to track how long individual players take for decisions. Perfect for tournament judges to monitor slow play.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    }
                    
                    // Appearance Section
                    VStack(spacing: 16) {
                        Text("Appearance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    gameState.colorScheme = .light
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.title2)
                                    Text("Light")
                                        .font(.caption)
                                }
                                .foregroundColor(gameState.colorScheme == .light ? .blue : .primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(gameState.colorScheme == .light ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    gameState.colorScheme = .dark
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "moon.fill")
                                        .font(.title2)
                                    Text("Dark")
                                        .font(.caption)
                                }
                                .foregroundColor(gameState.colorScheme == .dark ? .blue : .primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(gameState.colorScheme == .dark ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                            }
                        }
                    }
                    
                    // Reset Game Section
                    VStack(spacing: 12) {
                        Text("Game Controls")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("Reset Game") {
                            showingResetConfirmation = true
                        }
                        .buttonStyle(DangerButtonStyle())
                    }
                    
                    Spacer(minLength: 50)
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(PassTurnButtonStyle())
                    .padding(.bottom)
                }
                .padding()
            }
            .applyNavigationStyle()
        }
        .applyAlert(
            isPresented: $showingResetConfirmation,
            onReset: {
                gameState.resetGame()
                isPresented = false
            }
        )
    }
}