import Combine
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var theme: KoTheme
    @EnvironmentObject private var flow: FlowLines
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            GlowLayer()

            VStack(spacing: 24) {
                header
                    .padding(.top, 28)
                    .padding(.horizontal, 26)

                contentCard
                    .padding(.horizontal, 26)

                Spacer()

                closeButton
                    .padding(.bottom, 28)
                    .padding(.horizontal, 26)
            }
            .opacity(vm.fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 0.3), value: vm.fadeIn)
        }
        .onAppear {
            vm.onAppear()
        }
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(KoPalette.textPrimary)
                .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 3)

            Spacer()
        }
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: KoIcons.tile)
                    .foregroundColor(KoPalette.accentGlow)

                Text("MahjKo is tuned for calm, simple play.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(KoPalette.textPrimary)
            }

            Text("The game has no timers and no complicated menus. You can close and return any time, your next board is always ready.")
                .font(.system(size: 14))
                .foregroundColor(KoPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .background(KoPalette.borderSoft)

            HStack(spacing: 8) {
                Image(systemName: KoIcons.spark)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(KoPalette.accent)

                Text("Tip: if you enjoy the flow, one more quick round is always a good idea.")
                    .font(.system(size: 13))
                    .foregroundColor(KoPalette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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

    private var closeButton: some View {
        Button {
            vm.close(flow: flow)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: KoIcons.back)
                    .font(.system(size: 16, weight: .semibold))

                Text("Back")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(KoPalette.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(KoPalette.card)
                    .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ViewModel

final class SettingsViewModel: ObservableObject {
    @Published var fadeIn: Bool = false

    func onAppear() {
        withAnimation(.easeOut(duration: 0.3)) {
            fadeIn = true
        }
    }

    func close(flow: FlowLines) {
        KoHaptics.shared.tapSoft()
        flow.closeCurrent()
    }
}
