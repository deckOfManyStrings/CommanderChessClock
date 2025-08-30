//
//  ContentView.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                mainContentView(geometry: geometry)
                centerControls(geometry: geometry)
                overlayView
            }
        }
        .applyColorScheme(gameState.colorScheme)
        .sheet(isPresented: $gameState.showingOptions) {
            optionsSheet
        }
    }
    
    // MARK: - Responsive Layout Components
    
    private var backgroundView: some View {
        Group {
            if #available(iOS 14.0, *) {
                (gameState.colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
            } else {
                (gameState.colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func mainContentView(geometry: GeometryProxy) -> some View {
        let isCompactHeight = geometry.size.height < 500
        let spacing = isCompactHeight ? 4.0 : 8.0
        
        return VStack(spacing: spacing) {
            topRowView(geometry: geometry, isCompact: isCompactHeight)
            bottomRowView(geometry: geometry, isCompact: isCompactHeight)
        }
    }
    
    private func topRowView(geometry: GeometryProxy, isCompact: Bool) -> some View {
        let spacing = isCompact ? 4.0 : 8.0
        let heightAdjustment = isCompact ? 32.0 : 16.0
        
        return HStack(spacing: spacing) {
            // Player 1 (Top Left) - Rotated 180°
            PlayerQuadrantView(
                playerIndex: 0,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 0 && !gameState.priorityHeld
            )
            .frame(
                width: (geometry.size.width - (spacing * 2)) / 2,
                height: (geometry.size.height - heightAdjustment) / 2
            )
            .rotationEffect(.degrees(180))
            
            // Player 2 (Top Right) - Rotated 180°
            PlayerQuadrantView(
                playerIndex: 1,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 1 && !gameState.priorityHeld
            )
            .frame(
                width: (geometry.size.width - (spacing * 2)) / 2,
                height: (geometry.size.height - heightAdjustment) / 2
            )
            .rotationEffect(.degrees(180))
        }
    }
    
    private func bottomRowView(geometry: GeometryProxy, isCompact: Bool) -> some View {
        let spacing = isCompact ? 4.0 : 8.0
        let heightAdjustment = isCompact ? 32.0 : 16.0
        
        return HStack(spacing: spacing) {
            // Player 4 (Bottom Left) - Normal orientation
            PlayerQuadrantView(
                playerIndex: 3,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 3 && !gameState.priorityHeld
            )
            .frame(
                width: (geometry.size.width - (spacing * 2)) / 2,
                height: (geometry.size.height - heightAdjustment) / 2
            )
            
            // Player 3 (Bottom Right) - Normal orientation
            PlayerQuadrantView(
                playerIndex: 2,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 2 && !gameState.priorityHeld
            )
            .frame(
                width: (geometry.size.width - (spacing * 2)) / 2,
                height: (geometry.size.height - heightAdjustment) / 2
            )
        }
    }
    
    private func centerControls(geometry: GeometryProxy) -> some View {
        let isCompactHeight = geometry.size.height < 500
        
        return HStack(spacing: isCompactHeight ? 12 : 16) {
            // Options button - remove background
            Button(action: {
                gameState.showingOptions = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: isCompactHeight ? 14 : 16))
                    .foregroundColor(.white)
                    .frame(width: isCompactHeight ? 28 : 32, height: isCompactHeight ? 28 : 32)
            }
            
            // Main center button - only show if clock is enabled
            if gameState.clockEnabled {
                if !gameState.gameStarted {
                    if isCompactHeight {
                        Button("Start Clock") {
                            gameState.startGame()
                        }
                        .buttonStyle(CompactStartGameButtonStyle())
                    } else {
                        Button("Start Clock") {
                            gameState.startGame()
                        }
                        .buttonStyle(StartGameButtonStyle())
                    }
                } else {
                    if isCompactHeight {
                        Button("Pass Turn") {
                            gameState.passTurn()
                        }
                        .buttonStyle(CompactPassTurnButtonStyle())
                    } else {
                        Button("Pass Turn") {
                            gameState.passTurn()
                        }
                        .buttonStyle(PassTurnButtonStyle())
                    }
                }
                
                // Pause/Resume button (only visible when game has started)
                if gameState.gameStarted {
                    Button(action: {
                        gameState.togglePause()
                    }) {
                        Image(systemName: gameState.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: isCompactHeight ? 14 : 16))
                            .foregroundColor(.white)
                            .frame(width: isCompactHeight ? 28 : 32, height: isCompactHeight ? 28 : 32)
                            .background(
                                Circle()
                                    .fill(gameState.isPaused ? Color.green.opacity(0.8) : Color.orange.opacity(0.8))
                            )
                    }
                }
            }
        }
        .padding(isCompactHeight ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: isCompactHeight ? 10 : 12)
                .fill(Color.black.opacity(0.8))
        )
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if gameState.isTimingPlayer {
            CallTimeOverlayView(gameState: gameState)
        }
    }
    
    @ViewBuilder
    private var optionsSheet: some View {
        if #available(iOS 16.0, *) {
            OptionsView(gameState: gameState, isPresented: $gameState.showingOptions)
                .presentationDetents([.medium, .large])
        } else {
            OptionsView(gameState: gameState, isPresented: $gameState.showingOptions)
        }
    }
}

// MARK: - Clean Button Styles (No Background)
struct CompactStartGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct CompactPassTurnButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .applyButtonAnimation(configuration.isPressed)
    }
}

// MARK: - Preview
#if swift(>=5.9)
#Preview {
    ContentView()
}
#else
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
