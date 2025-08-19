import SwiftUI

@main
struct CommanderChessClockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyAppModifiers()
        }
    }
}

// MARK: - App-level View Extensions
extension View {
    @ViewBuilder
    func applyAppModifiers() -> some View {
        if #available(iOS 16.0, *) {
            // iOS 16+ with all modern features
            self
                .preferredColorScheme(.light)
                .persistentSystemOverlays(.hidden)
                .ignoresSafeArea(.all)
        } else if #available(iOS 14.0, *) {
            // iOS 14-15 with available features
            self
                .preferredColorScheme(.light)
                .ignoresSafeArea(.all)
        } else {
            // iOS 13 fallback
            self
                .colorScheme(.light)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
