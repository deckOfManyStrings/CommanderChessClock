//
//  CallTimeOverlayView.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//


import SwiftUI

struct CallTimeOverlayView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("TIMING PLAYER \(gameState.timedPlayerIndex.map { $0 + 1 } ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(gameState.formattedCallTime())
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("Judge Timer")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack(spacing: 20) {
                Button("Stop Timing") {
                    gameState.stopTimingPlayer()
                }
                .buttonStyle(StopTimingButtonStyle())
                
                Button("Reset Timer") {
                    gameState.resetCallTime()
                }
                .buttonStyle(ResetTimingButtonStyle())
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red, lineWidth: 2)
                )
        )
        .shadow(radius: 10)
    }
}
