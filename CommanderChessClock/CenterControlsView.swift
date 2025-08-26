//
//  CenterControlsView.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//


import SwiftUI

struct CenterControlsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        HStack(spacing: 16) {
            // Options button
            Button(action: {
                gameState.showingOptions = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.8))
                    )
            }
            
            // Main center button - only show if clock is enabled
            if gameState.clockEnabled {
                if !gameState.gameStarted {
                    Button("Start Clock") {
                        gameState.startGame()
                    }
                    .buttonStyle(StartGameButtonStyle())
                } else {
                    Button("Pass Turn") {
                        gameState.passTurn()
                    }
                    .buttonStyle(PassTurnButtonStyle())
                }
                
                // Pause/Resume button (only visible when game has started)
                if gameState.gameStarted {
                    Button(action: {
                        gameState.togglePause()
                    }) {
                        Image(systemName: gameState.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(gameState.isPaused ? Color.green.opacity(0.8) : Color.orange.opacity(0.8))
                            )
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
        )
    }
}