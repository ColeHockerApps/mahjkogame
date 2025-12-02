import Combine
import SwiftUI

struct HubScreen: View {
    @EnvironmentObject private var theme: KoTheme
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var echo: StarEcho
    @EnvironmentObject private var streaks: StreakEngine
    @EnvironmentObject private var quests: QuestEngine
    @EnvironmentObject private var daylight: DaylightEngine

    @StateObject private var vm = HubViewModel()

    var body: some View {
        ZStack {
            backgroundLayer
            GlowLayer().opacity(0.28)

            VStack(spacing: 22) {
                topButtons
                    .padding(.top, 22)
                    .padding(.horizontal, 22)

                Spacer(minLength: 12)

                streakSection
                    .padding(.horizontal, 26)

                questsSection
                    .padding(.horizontal, 26)

                playButton
                    .padding(.top, 8)

                if !vm.tagline.isEmpty {
                    Text(vm.tagline)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                if !vm.todaySummary.isEmpty {
                    Text(vm.todaySummary)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(.bottom, 12)
                }
            }
            .opacity(vm.fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 0.35), value: vm.fadeIn)
        }
        .onAppear {
            daylight.refreshNow()
            vm.onAppear(echo: echo)
            quests.syncStreakValue(streaks.currentStreak)
        }
    }

    // MARK: Background

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.10, blue: 0.14),
                Color(red: 0.06, green: 0.06, blue: 0.10)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: Top buttons

    private var topButtons: some View {
        HStack(spacing: 14) {
            topButton(symbol: KoIcons.book, label: "Rules") {
                vm.openRules(flow: flow)
            }

            topButton(symbol: KoIcons.shield, label: "Privacy") {
                vm.openPolicy(flow: flow)
            }

            Spacer()
        }
    }

    private func topButton(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: Streak section

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily streak")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if streaks.currentStreak > 0 {
                    Text("\(streaks.currentStreak) day\(streaks.currentStreak == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                let ratio = streaks.streakProgress(target: 7)

                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.18))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [KoPalette.accent, KoPalette.accentDeep],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, width * ratio))
                }
            }
            .frame(height: 10)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
    }

    // MARK: Quests

    private var questsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !quests.quests.isEmpty {
                Text("Today’s tiny goals")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            ForEach(quests.quests) { quest in
                questRow(quest)
            }
        }
        .padding(.vertical, quests.quests.isEmpty ? 0 : 10)
        .padding(.horizontal, quests.quests.isEmpty ? 0 : 14)
        .background(
            Group {
                if quests.quests.isEmpty {
                    Color.clear
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                }
            }
        )
        .shadow(
            color: quests.quests.isEmpty ? .clear : Color.black.opacity(0.25),
            radius: 10,
            x: 0,
            y: 5
        )
    }

    private func questRow(_ quest: DailyQuest) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(quest.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(min(quest.progress, quest.target))/\(quest.target)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.75))
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                let ratio = quest.progressRatio

                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.20))
                    Capsule()
                        .fill(
                            quest.isCompleted
                            ? Color.green.opacity(0.85)
                            : KoPalette.accentDeep.opacity(0.9)
                        )
                        .frame(width: max(0, width * ratio))
                }
            }
            .frame(height: 8)

            Text(quest.detail)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.55))
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }

    // MARK: Play button

    private var playButton: some View {
        Button {
            vm.play(flow: flow, echo: echo, streaks: streaks, quests: quests)
        } label: {
            Text("Play")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [KoPalette.accent, KoPalette.accentDeep],
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

// MARK: ViewModel

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

    func play(flow: FlowLines, echo: StarEcho, streaks: StreakEngine, quests: QuestEngine) {
        KoHaptics.shared.tapMedium()
        streaks.registerToday()
        quests.registerBoardOpened()
        quests.syncStreakValue(streaks.currentStreak)
        echo.registerSession()
        echo.maybeAskForReview()
        flow.goBoard()
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
