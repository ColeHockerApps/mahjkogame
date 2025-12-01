import Combine
import SwiftUI

struct KoPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(KoPalette.textPrimary)
                .padding(.horizontal, 26)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    KoPalette.accent,
                                    KoPalette.accentDeep
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: KoPalette.accentDeep.opacity(0.55),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct KoSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(KoPalette.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(KoPalette.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(KoPalette.borderSoft, lineWidth: 1)
                        )
                        .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
    }
}

struct KoBadgeButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(KoPalette.accentGlow)

                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(KoPalette.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(KoPalette.panel)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(KoPalette.borderSoft, lineWidth: 1)
                    )
                    .shadow(color: KoPalette.softShadow, radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

struct KoInfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(KoPalette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(KoPalette.borderSoft, lineWidth: 1)
                    )
                    .shadow(color: KoPalette.softShadow, radius: 12, x: 0, y: 6)
            )
    }
}

extension View {
    func koTitleStyle() -> some View {
        self
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(KoPalette.textPrimary)
    }

    func koBodyStyle() -> some View {
        self
            .font(.system(size: 14))
            .foregroundColor(KoPalette.textSecondary)
    }

    func koCaptionStyle() -> some View {
        self
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(KoPalette.textMuted)
    }
}
