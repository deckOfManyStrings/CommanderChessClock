//
//  ButtonStyles.swift
//  CommanderChessClock
//
//  Created by Bobby Kingsada on 8/25/25.
//

import SwiftUI

// MARK: - Button Styles
struct LifeButtonStyle: ButtonStyle {
    let colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct PriorityButtonStyle: ButtonStyle {
    let isHolding: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isHolding ? Color.red : Color.orange)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct CallTimeButtonStyle: ButtonStyle {
    let isBeingTimed: Bool
    let colorScheme: ColorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isBeingTimed ? Color.red : Color.blue)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct StopTimingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.red)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct ResetTimingButtonStyle: ButtonStyle {
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

struct PassTurnButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .applyButtonAnimation(configuration.isPressed)
    }
}

struct StartGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.green)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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
