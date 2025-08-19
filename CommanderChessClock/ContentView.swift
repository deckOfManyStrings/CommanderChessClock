import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Use newer API when available
                if #available(iOS 14.0, *) {
                    (gameState.colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
                } else {
                    (gameState.colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
                }
                
                // Player quadrants with proper spacing - players 1&2 rotated 180°
                VStack(spacing: 8) {
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
                
                // Center control area
                CenterControlsView(gameState: gameState)
            }
        }
        .onAppear {
            // Don't auto-start the game
        }
        .applyColorScheme(gameState.colorScheme)
        .sheet(isPresented: $gameState.showingOptions) {
            if #available(iOS 16.0, *) {
                OptionsView(gameState: gameState, isPresented: $gameState.showingOptions)
                    .presentationDetents([.medium, .large])
            } else {
                OptionsView(gameState: gameState, isPresented: $gameState.showingOptions)
            }
        }
    }
}

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
            
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                )
            
            VStack(spacing: 12) {
                // Life total controls
                HStack(spacing: 16) {
                    Button("-") {
                        gameState.decrementLife(for: playerIndex)
                    }
                    .buttonStyle(LifeButtonStyle(colorScheme: gameState.colorScheme))
                    
                    Text("\(gameState.players[playerIndex].life)")
                        .applyLifeFont()
                        .foregroundColor(textColor)
                        .frame(minWidth: 50)
                    
                    Button("+") {
                        gameState.incrementLife(for: playerIndex)
                    }
                    .buttonStyle(LifeButtonStyle(colorScheme: gameState.colorScheme))
                }
                
                // Timer display
                Text(gameState.formattedTime(for: playerIndex))
                    .applyTimerFont()
                    .foregroundColor(textColor)
                
                // Priority button
                Button(gameState.priorityPlayerIndex == playerIndex ? "Release Priority" : "Hold Priority") {
                    gameState.togglePriority(for: playerIndex)
                }
                .buttonStyle(PriorityButtonStyle(isHolding: gameState.priorityPlayerIndex == playerIndex))
            }
            .padding(12)
        }
    }
}

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
            
            // Main center button (Start Game, Pass Turn, or Resume)
            if !gameState.gameStarted {
                Button("Start Game") {
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
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
        )
    }
}

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
    
    private var timer: Timer?
    private let totalPlayers = 4
    
    init() {
        setupPlayers()
    }
    
    private func setupPlayers() {
        players = (0..<totalPlayers).map { _ in Player() }
    }
    
    func startGame() {
        gameStarted = true
        isPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateTimer()
        }
    }
    
    private func updateTimer() {
        // Only update if game is not paused
        guard !isPaused else { return }
        
        if priorityHeld, let priorityIndex = priorityPlayerIndex {
            players[priorityIndex].elapsedTime += 0.1
        } else {
            players[activePlayerIndex].elapsedTime += 0.1
        }
    }
    
    func togglePause() {
        isPaused.toggle()
    }
    
    func passTurn() {
        // Release priority when passing turn
        priorityHeld = false
        priorityPlayerIndex = nil
        
        // Move to next player (round robin)
        activePlayerIndex = (activePlayerIndex + 1) % totalPlayers
    }
    
    func togglePriority(for playerIndex: Int) {
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
        let elapsedTime = players[playerIndex].elapsedTime
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let centiseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, centiseconds)
    }
    
    func resetGame() {
        timer?.invalidate()
        setupPlayers()
        activePlayerIndex = 0
        priorityHeld = false
        priorityPlayerIndex = nil
        gameStarted = false
        isPaused = false
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Player Model
struct Player {
    var life: Int = 40
    var elapsedTime: Double = 0.0
}

// MARK: - View Extensions for Compatibility
extension View {
    @ViewBuilder
    func applyColorScheme(_ colorScheme: ColorScheme) -> some View {
        if #available(iOS 14.0, *) {
            self.preferredColorScheme(colorScheme)
        } else {
            self.colorScheme(colorScheme)
        }
    }
    
    @ViewBuilder
    func applyLifeFont() -> some View {
        if #available(iOS 16.0, *) {
            self.font(.system(size: 32, weight: .bold, design: .rounded))
        } else {
            self.font(Font.system(size: 32).weight(.bold))
        }
    }
    
    @ViewBuilder
    func applyTimerFont() -> some View {
        if #available(iOS 15.0, *) {
            self.font(.system(size: 16, weight: .medium, design: .monospaced))
        } else if #available(iOS 14.0, *) {
            self.font(Font.system(size: 16).weight(.medium).monospacedDigit())
        } else {
            self.font(Font.system(size: 16).weight(.medium))
        }
    }
    
    @ViewBuilder
    func applyNavigationStyle() -> some View {
        if #available(iOS 14.0, *) {
            self.navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        } else {
            self.navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    func applyAlert(isPresented: Binding<Bool>, onReset: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.alert("Reset Game?", isPresented: isPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    onReset()
                }
            } message: {
                Text("This will reset all player life totals to 40 and restart all timers. This action cannot be undone.")
            }
        } else {
            self.alert(isPresented: isPresented) {
                Alert(
                    title: Text("Reset Game?"),
                    message: Text("This will reset all player life totals to 40 and restart all timers. This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        onReset()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// MARK: - Button Styles
struct LifeButtonStyle: ButtonStyle {
    let colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .frame(width: 40, height: 40)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct PriorityButtonStyle: ButtonStyle {
    let isHolding: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isHolding ? Color.red : Color.orange)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct PassTurnButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct StartGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.green)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.red)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

// Extension for button animations
extension View {
    @ViewBuilder
    func applyButtonAnimation(_ isPressed: Bool) -> some View {
        if #available(iOS 15.0, *) {
            self.animation(.easeInOut(duration: 0.1), value: isPressed)
        } else {
            self.animation(.easeInOut(duration: 0.1))
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
