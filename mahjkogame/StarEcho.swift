import Combine
import SwiftUI
import StoreKit

final class StarEcho: ObservableObject {
    @Published var launchCount: Int = 0
    @Published var sessionCount: Int = 0

    private let launchKey = "mahjko.echo.launches"
    private let sessionKey = "mahjko.echo.sessions"
    private let lastDateKey = "mahjko.echo.lastdate"

    init() {
        let defaults = UserDefaults.standard

        let today = Calendar.current.startOfDay(for: Date())
        let last = defaults.object(forKey: lastDateKey) as? Date

        if last == nil || Calendar.current.isDate(last!, inSameDayAs: today) == false {
            defaults.set(today, forKey: lastDateKey)
            sessionCount = 0
            defaults.set(sessionCount, forKey: sessionKey)
        } else {
            sessionCount = defaults.integer(forKey: sessionKey)
        }

        launchCount = defaults.integer(forKey: launchKey)
        launchCount += 1
        defaults.set(launchCount, forKey: launchKey)
    }

    func registerSession() {
        sessionCount += 1
        UserDefaults.standard.set(sessionCount, forKey: sessionKey)
    }

    func maybeAskForReview() {
        guard launchCount > 3, sessionCount > 2 else { return }
        guard Int.random(in: 0...5) == 0 else { return }

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
