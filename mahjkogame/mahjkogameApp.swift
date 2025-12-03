import Combine
import SwiftUI

@main
struct MahjKoApp: App {
    @StateObject private var theme = KoTheme()
    @StateObject private var palette = KoPalette()
    @StateObject private var icons = KoIcons()
    @StateObject private var haptics = KoHaptics()
    @StateObject private var ledger = PathLedger()
    @StateObject private var echo = StarEcho()
    @StateObject private var flow = FlowLines()

    @StateObject private var streaks = StreakEngine()
    @StateObject private var mood = MoodEngine()
    @StateObject private var quests = QuestEngine()
    @StateObject private var daylight = DaylightEngine()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(theme)
                .environmentObject(palette)
                .environmentObject(icons)
                .environmentObject(haptics)
                .environmentObject(ledger)
                .environmentObject(echo)
                .environmentObject(flow)
                .environmentObject(streaks)
                .environmentObject(mood)
                .environmentObject(quests)
                .environmentObject(daylight)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var theme: KoTheme

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            switch flow.current {
            case .onboarding:
                OnboardingScreen()

            case .hub:
                HubScreen()

            case .board:
                BoardStage()

            case .settings:
                SettingsScreen()

            case .rules:
                RulesScreen()

            case .policy:
                PolicyScreen()

            case .tutorial:
                TutorialGameScreen()

            case .dailyPopup:
                DailyPopupScreen()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: flow.current)
    }
}
