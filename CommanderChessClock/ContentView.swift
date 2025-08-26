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
                // Background
                backgroundView
                
                // Main content - use simpler structure
                mainContentView(geometry: geometry)
                
                // Center controls
                CenterControlsView(gameState: gameState)
                
                // Overlay - conditionally shown
                overlayView
            }
        }
        .onAppear {
            // Don't auto-start the game
        }
        .applyColorScheme(gameState.colorScheme)
        .sheet(isPresented: $gameState.showingOptions) {
            optionsSheet
        }
    }
    
    // MARK: - Subviews broken down to avoid complex nesting
    
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
        VStack(spacing: 8) {
            topRowView(geometry: geometry)
            bottomRowView(geometry: geometry)
        }
    }
    
    private func topRowView(geometry: GeometryProxy) -> some View {
        HStack(spacing: 8) {
            // Player 1 (Top Left) - Rotated 180°
            PlayerQuadrantView(
                playerIndex: 0,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 0 && !gameState.priorityHeld
            )
            .frame(width: (geometry.size.width - 16) / 2, height: (geometry.size.height - 16) / 2)
            .rotationEffect(.degrees(180))
            
            // Player 2 (Top Right) - Rotated 180°
            PlayerQuadrantView(
                playerIndex: 1,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 1 && !gameState.priorityHeld
            )
            .frame(width: (geometry.size.width - 16) / 2, height: (geometry.size.height - 16) / 2)
            .rotationEffect(.degrees(180))
        }
    }
    
    private func bottomRowView(geometry: GeometryProxy) -> some View {
        HStack(spacing: 8) {
            // Player 4 (Bottom Left) - Normal orientation
            PlayerQuadrantView(
                playerIndex: 3,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 3 && !gameState.priorityHeld
            )
            .frame(width: (geometry.size.width - 16) / 2, height: (geometry.size.height - 16) / 2)
            
            // Player 3 (Bottom Right) - Normal orientation
            PlayerQuadrantView(
                playerIndex: 2,
                gameState: gameState,
                isActive: gameState.activePlayerIndex == 2 && !gameState.priorityHeld
            )
            .frame(width: (geometry.size.width - 16) / 2, height: (geometry.size.height - 16) / 2)
        }
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
