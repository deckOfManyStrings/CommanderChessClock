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
                // Life total controls - increased spacing and made more prominent
                HStack(spacing: 20) {
                    Button("-") {
                        gameState.decrementLife(for: playerIndex)
                    }
                    .buttonStyle(LifeButtonStyle(colorScheme: gameState.colorScheme))
                    
                    Text("\(gameState.players[playerIndex].life)")
                        .applyLifeFont()
                        .foregroundColor(textColor)
                        .frame(minWidth: 80)
                    
                    Button("+") {
                        gameState.incrementLife(for: playerIndex)
                    }
                    .buttonStyle(LifeButtonStyle(colorScheme: gameState.colorScheme))
                }
                
                // Timer display - only show if clock is enabled
                if gameState.clockEnabled {
                    Text(gameState.formattedTime(for: playerIndex))
                        .applyTimerFont()
                        .foregroundColor(textColor)
                    
                    // Priority button - only show if clock is enabled
                    Button(gameState.priorityPlayerIndex == playerIndex ? "Release Priority" : "Hold Priority") {
                        gameState.togglePriority(for: playerIndex)
                    }
                    .buttonStyle(PriorityButtonStyle(isHolding: gameState.priorityPlayerIndex == playerIndex))
                }
                
                // Call Time button - always available
                Button("Call Time") {
                    gameState.startTimingPlayer(playerIndex)
                }
                .buttonStyle(CallTimeButtonStyle(
                    isBeingTimed: isBeingTimed,
                    colorScheme: gameState.colorScheme
                ))
                .disabled(gameState.isTimingPlayer && gameState.timedPlayerIndex != playerIndex)
            }
            .padding(16)
        }
    }
}
