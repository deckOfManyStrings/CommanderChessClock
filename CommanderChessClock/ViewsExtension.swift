//
//  ViewsExtension.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//

import SwiftUI

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
            self.font(.system(size: 48, weight: .bold, design: .rounded))
        } else {
            self.font(Font.system(size: 48).weight(.bold))
        }
    }
    
    @ViewBuilder
    func applyTimerFont() -> some View {
        if #available(iOS 15.0, *) {
            self.font(.system(size: 18, weight: .medium, design: .monospaced))
        } else if #available(iOS 14.0, *) {
            self.font(Font.system(size: 18).weight(.medium).monospacedDigit())
        } else {
            self.font(Font.system(size: 18).weight(.medium))
        }
    }
    
    @ViewBuilder
    func applyNavigationStyle() -> some View {
        self.navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
    }
    
    @ViewBuilder
    func applyAlert(isPresented: Binding<Bool>, onReset: @escaping () -> Void) -> some View {
        self.alert("Reset Game?", isPresented: isPresented) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                onReset()
            }
        } message: {
            Text("This will reset all player life totals to 40 and restart all timers. This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    func applyButtonAnimation(_ isPressed: Bool) -> some View {
        if #available(iOS 15.0, *) {
            self.animation(.easeInOut(duration: 0.1), value: isPressed)
        } else {
            self.animation(.easeInOut(duration: 0.1))
        }
    }
}
