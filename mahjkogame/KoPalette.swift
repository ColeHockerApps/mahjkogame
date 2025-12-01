import Combine
import SwiftUI

final class KoPalette: ObservableObject {
    // Main text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textMuted = Color.white.opacity(0.55)

    // Surfaces
    static let card = Color.white.opacity(0.15)
    static let panel = Color.white.opacity(0.10)
    static let overlay = Color.black.opacity(0.25)

    // Borders
    static let borderSoft = Color.white.opacity(0.20)
    static let borderBold = Color.white.opacity(0.35)

    // Highlights
    static let accent = Color(red: 1.0, green: 0.86, blue: 0.45)
    static let accentDeep = Color(red: 0.94, green: 0.54, blue: 0.33)
    static let accentGlow = Color(red: 1.0, green: 0.93, blue: 0.65)

    // Shadows
    static let softShadow = Color.black.opacity(0.28)

    // Utility
    static let dim = Color.black.opacity(0.55)
    static let glassStroke = Color.white.opacity(0.18)
}
