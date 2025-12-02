import Combine
import SwiftUI

final class StreakEngine: ObservableObject {
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0
    @Published private(set) var lastActiveDay: Date?

    private let streakKey = "streak.current.value"
    private let longestKey = "streak.longest.value"
    private let lastDayKey = "streak.last.day"

    private let calendar = Calendar.current

    init() {
        let defaults = UserDefaults.standard

        currentStreak = defaults.integer(forKey: streakKey)
        longestStreak = defaults.integer(forKey: longestKey)

        if let stored = defaults.object(forKey: lastDayKey) as? Date {
            lastActiveDay = stored
            restoreForToday(from: stored)
        }
    }

    func registerToday() {
        let today = stripTime(from: Date())

        if let last = lastActiveDay {
            let lastDay = stripTime(from: last)

            if calendar.isDate(lastDay, inSameDayAs: today) {
                return
            }

            if let distance = calendar.dateComponents([.day], from: lastDay, to: today).day,
               distance == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        lastActiveDay = today
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        persist()
    }

    func resetAll() {
        currentStreak = 0
        longestStreak = 0
        lastActiveDay = nil
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: streakKey)
        defaults.removeObject(forKey: longestKey)
        defaults.removeObject(forKey: lastDayKey)
    }

    func streakProgress(target: Int) -> Double {
        guard target > 0 else { return 0 }
        let value = min(currentStreak, target)
        return Double(value) / Double(target)
    }

    private func restoreForToday(from stored: Date) {
        let today = stripTime(from: Date())
        let storedDay = stripTime(from: stored)

        if calendar.isDate(storedDay, inSameDayAs: today) {
            return
        }

        if let distance = calendar.dateComponents([.day], from: storedDay, to: today).day,
           distance == 1 {
            return
        }

        currentStreak = 0
        persist()
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(currentStreak, forKey: streakKey)
        defaults.set(longestStreak, forKey: longestKey)
        if let day = lastActiveDay {
            defaults.set(day, forKey: lastDayKey)
        }
    }

    private func stripTime(from date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: comps) ?? date
    }
}
