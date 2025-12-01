import Combine
import SwiftUI

struct RulesScreen: View {
    @EnvironmentObject private var theme: KoTheme
    @EnvironmentObject private var flow: FlowLines
    @StateObject private var vm = RulesViewModel()

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            GlowLayer()

            VStack(spacing: 24) {
                header
                    .padding(.top, 28)
                    .padding(.horizontal, 26)

                rulesCard
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
            Text("How to play")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(KoPalette.textPrimary)
                .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 3)

            Spacer()
        }
    }

    private var rulesCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ruleBlock(
                    title: "Goal",
                    text: "Clear the board by matching identical tiles. When all tiles are gone, the board is complete."
                )

                ruleBlock(
                    title: "Free tiles",
                    text: "A tile is considered free when it is not covered by another tile and has at least one open side. Only free tiles can be selected."
                )

                ruleBlock(
                    title: "Matching",
                    text: "Tap one free tile, then tap another identical free tile. If they form a valid pair, they disappear together."
                )

                ruleBlock(
                    title: "No rush",
                    text: "MahjKo is not timed. You can take a break, think through the next move, and come back to the board whenever you like."
                )

                ruleBlock(
                    title: "Stuck?",
                    text: "If you run out of moves, simply refresh or start a new layout. Sometimes a fresh board is all you need."
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Play style")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(KoPalette.textPrimary)

                    Text("You can play in short bursts or longer sessions. The game is built to feel light and simple, so even a few quick matches can be enough.")
                        .font(.system(size: 14))
                        .foregroundColor(KoPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
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
            .padding(.bottom, 4)
        }
    }

    private func ruleBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: KoIcons.tile)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(KoPalette.accentGlow)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(KoPalette.textPrimary)
            }

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(KoPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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

final class RulesViewModel: ObservableObject {
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
