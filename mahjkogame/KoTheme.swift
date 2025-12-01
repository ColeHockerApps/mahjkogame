import Combine
import SwiftUI

final class KoTheme: ObservableObject {

    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.78, blue: 0.52),
                Color(red: 0.93, green: 0.55, blue: 0.38),
                Color(red: 0.85, green: 0.32, blue: 0.34)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var tileGlow: Color {
        Color(red: 1.0, green: 0.92, blue: 0.62)
    }

    var shadowSoft: Color {
        Color.black.opacity(0.25)
    }

    var surface: Color {
        Color.white.opacity(0.18)
    }

    var titleFont: Font {
        .system(size: 32, weight: .heavy)
    }

    var bodyFont: Font {
        .system(size: 16, weight: .medium)
    }
}
