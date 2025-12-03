import Combine
import SwiftUI

enum DailyPopupEngine {
    private static let lastShownKey = "mahjko.dailyPopup.lastShown"

    static func showIfNeeded(flow: FlowLines) {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())

        if let last = defaults.object(forKey: lastShownKey) as? Date,
           Calendar.current.isDate(last, inSameDayAs: today) {
            return
        }

        defaults.set(today, forKey: lastShownKey)
        flow.goDailyPopup()
    }
}
