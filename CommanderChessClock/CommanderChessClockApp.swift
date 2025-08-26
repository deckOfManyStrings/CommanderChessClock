import SwiftUI
import UIKit

@main
struct CommanderChessClockApp: App {
    @StateObject private var appDelegate = AppDelegate()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .applyAppModifiers()
                .environmentObject(appDelegate)
                .onAppear {
                    // Keep screen awake when app appears
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                    // Force landscape orientation
                    AppDelegate.orientationLock = .landscape
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if #available(iOS 16.0, *) {
                            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
                        } else {
                            // For iOS 15 and below, use the older method
                            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                        }
                    }
                }
                .onDisappear {
                    // Allow screen to sleep when app disappears
                    UIApplication.shared.isIdleTimerDisabled = false
                    
                    // Reset orientation lock when app disappears
                    AppDelegate.orientationLock = .all
                }
        }
    }
}

// MARK: - App Delegate for additional lifecycle management
class AppDelegate: NSObject, ObservableObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Allow screen to sleep when app goes to background
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Keep screen awake when app becomes active
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Reapply landscape lock when app becomes active
        AppDelegate.orientationLock = .landscape
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Reset idle timer and orientation when app terminates
        UIApplication.shared.isIdleTimerDisabled = false
        AppDelegate.orientationLock = .all
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
