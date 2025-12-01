import Combine
import SwiftUI

struct HubScreen: View {
    @EnvironmentObject private var theme: KoTheme
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var echo: StarEcho

    @StateObject private var vm = HubViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.94, blue: 0.88),
                    Color(red: 0.96, green: 0.90, blue: 0.82),
                    Color(red: 0.94, green: 0.88, blue: 0.80)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.55),
                    Color.clear
                ],
                center: .center,
                startRadius: 80,
                endRadius: 420
            )
            .blendMode(.softLight)
            .ignoresSafeArea()

            GlowLayer()
                .opacity(0.35)

            VStack(spacing: 24) {
                topButtons
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                Spacer(minLength: 10)

                logoBlock
                    .padding(.horizontal, 24)

                playButton
                    .padding(.top, 8)

                if !vm.tagline.isEmpty {
                    Text(vm.tagline)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(KoPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                if !vm.todaySummary.isEmpty {
                    Text(vm.todaySummary)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(KoPalette.textMuted)
                        .padding(.bottom, 10)
                }
            }
            .opacity(vm.fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 0.35), value: vm.fadeIn)
        }
        .onAppear {
            vm.onAppear(echo: echo)
        }
    }

    // MARK: - Improved top buttons

    private var topButtons: some View {
        HStack(spacing: 14) {

            headerButton(symbol: KoIcons.gear, label: "Settings") {
                vm.openSettings(flow: flow)
            }

            headerButton(symbol: KoIcons.book, label: "Rules") {
                vm.openRules(flow: flow)
            }

            headerButton(symbol: KoIcons.shield, label: "Privacy") {
                vm.openPolicy(flow: flow)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func headerButton(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(KoPalette.textPrimary)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(KoPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .frame(minWidth: 110)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.92, green: 0.88, blue: 0.82))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.25), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
    // MARK: - Logo

    private var logoBlock: some View {
        Image("logo2")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 260)
            .scaleEffect(vm.logoScale)
            .shadow(color: KoPalette.softShadow, radius: 16, x: 0, y: 8)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Play button

    private var playButton: some View {
        Button {
            vm.play(flow: flow, echo: echo)
        } label: {
            Text("Play")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(KoPalette.textPrimary)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
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
                            radius: vm.playPulse ? 18 : 10,
                            x: 0,
                            y: vm.playPulse ? 10 : 4
                        )
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(vm.playPulse ? 1.04 : 1.0)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: vm.playPulse
        )
    }
}

// MARK: - ViewModel

final class HubViewModel: ObservableObject {
    @Published var fadeIn: Bool = false
    @Published var logoScale: CGFloat = 0.9
    @Published var playPulse: Bool = false
    @Published var tagline: String = ""
    @Published var todaySummary: String = ""

    private let taglines = [
        "Shuffle, match, exhale.",
        "A calm tap at a time.",
        "Tiles first, worries later.",
        "One more layout? Always.",
        "Soft focus, sharp moves."
    ]

    func onAppear(echo: StarEcho) {
        fadeIn = true

        withAnimation(.easeOut(duration: 0.4)) {
            logoScale = 1.0
        }

        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            playPulse = true
        }

        tagline = taglines.randomElement() ?? "Relax into the match."

        if echo.sessionCount > 0 {
            let suffix = echo.sessionCount == 1 ? "game" : "games"
            todaySummary = "Today: \(echo.sessionCount) \(suffix) played"
        } else {
            todaySummary = ""
        }
    }

    func play(flow: FlowLines, echo: StarEcho) {
        KoHaptics.shared.tapMedium()
        echo.registerSession()
        echo.maybeAskForReview()
        flow.goBoard()
    }

    func openSettings(flow: FlowLines) {
        KoHaptics.shared.tapLight()
        flow.goSettings()
    }

    func openRules(flow: FlowLines) {
        KoHaptics.shared.tapLight()
        flow.goRules()
    }

    func openPolicy(flow: FlowLines) {
        KoHaptics.shared.tapSoft()
        flow.goPolicy()
    }
}
