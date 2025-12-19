//
//  DesignSystem.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 19/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI
import AppKit

// MARK: - Design Tokens

/// Centralized design system for NanoPress following modern macOS design principles
enum NanoDesign {
    
    // MARK: - Gradients
    
    /// Blue-to-purple gradient for accent titles and icons
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.5, blue: 1.0),   // Vibrant blue
                Color(red: 0.6, green: 0.3, blue: 0.9)    // Rich purple
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Vertical gradient variant for larger elements
    static var accentGradientVertical: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.5, blue: 1.0),
                Color(red: 0.6, green: 0.3, blue: 0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - System Colors (Light/Dark Adaptive)
    
    static var windowBackground: Color {
        Color(NSColor.windowBackgroundColor)
    }
    
    static var controlBackground: Color {
        Color(NSColor.controlBackgroundColor)
    }
    
    static var separatorColor: Color {
        Color(NSColor.separatorColor)
    }
    
    // MARK: - Semantic Colors
    
    static var success: Color { .green }
    static var destructive: Color { .red }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 10
        static let large: CGFloat = 12
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        /// Subtle card shadow: 0.08 opacity
        static let cardOpacity: Double = 0.08
        static let cardRadius: CGFloat = 4
        static let cardY: CGFloat = 2
    }
    
    // MARK: - Borders
    
    enum Border {
        /// Subtle separator border width
        static let separator: CGFloat = 0.5
    }
}

// MARK: - Typography Extensions

extension Font {
    /// App title: 42pt bold rounded
    static var appTitle: Font {
        .system(size: 42, weight: .bold, design: .rounded)
    }
    
    /// Section headers: 22-28pt semibold rounded
    static func sectionHeader(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    /// Body medium: 14pt medium rounded for UI elements
    static var bodyMedium: Font {
        .system(size: 14, weight: .medium, design: .rounded)
    }
    
    /// Secondary text: 11-13pt regular
    static func secondaryText(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}

// MARK: - SF Symbol Configurations

extension Image {
    /// Hero icon configuration: 60-80pt light weight with hierarchical rendering
    func heroIconStyle(size: CGFloat = 70) -> some View {
        self
            .font(.system(size: size, weight: .light))
            .symbolRenderingMode(.hierarchical)
    }
    
    /// UI icon configuration: 14pt medium weight
    func uiIconStyle() -> some View {
        self
            .font(.system(size: 14, weight: .medium))
            .symbolRenderingMode(.hierarchical)
    }
}

// MARK: - Animation Presets

extension Animation {
    /// Spring animation for selection states
    static var selectionSpring: Animation {
        .spring(response: 0.3, dampingFraction: 0.6)
    }
    
    /// Quick spring for micro-interactions
    static var quickSpring: Animation {
        .spring(response: 0.2, dampingFraction: 0.7)
    }
}

// MARK: - View Modifiers

/// Card styling with subtle shadow and separator border
struct CardStyle: ViewModifier {
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.large)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.large)
                            .strokeBorder(
                                isSelected ? Color.accentColor : NanoDesign.separatorColor,
                                lineWidth: isSelected ? 2 : NanoDesign.Border.separator
                            )
                    )
                    .shadow(
                        color: .black.opacity(NanoDesign.Shadow.cardOpacity),
                        radius: NanoDesign.Shadow.cardRadius,
                        x: 0,
                        y: NanoDesign.Shadow.cardY
                    )
            )
    }
}

/// Selection animation with scale and accent glow
struct SelectionGlow: ViewModifier {
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0
            )
            .animation(.selectionSpring, value: isSelected)
    }
}

/// Gradient text modifier for titles
struct GradientText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(NanoDesign.accentGradient)
    }
}

extension View {
    /// Apply card styling with optional selection state
    func cardStyle(isSelected: Bool = false) -> some View {
        modifier(CardStyle(isSelected: isSelected))
    }
    
    /// Apply selection glow animation
    func selectionGlow(isSelected: Bool) -> some View {
        modifier(SelectionGlow(isSelected: isSelected))
    }
    
    /// Apply gradient text styling
    func gradientText() -> some View {
        modifier(GradientText())
    }
}

// MARK: - Gradient Button Style

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: NanoDesign.CornerRadius.small)
                    .fill(NanoDesign.accentGradient)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.quickSpring, value: configuration.isPressed)
            .shadow(
                color: Color(red: 0.4, green: 0.4, blue: 0.9).opacity(0.3),
                radius: configuration.isPressed ? 2 : 4,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
    }
}

extension ButtonStyle where Self == GradientButtonStyle {
    static var gradient: GradientButtonStyle { GradientButtonStyle() }
}
