import Combine
import SwiftUI

enum TableMood: String {
    case calm
    case focused
    case bright
    case intense

    var title: String {
        switch self {
        case .calm:
            return "Calm Table"
        case .focused:
            return "Focused Flow"
        case .bright:
            return "Bright Game"
        case .intense:
            return "Intense Run"
        }
    }

    var detail: String {
        switch self {
        case .calm:
            return "Short, easy sessions today."
        case .focused:
            return "Solid, balanced play time."
        case .bright:
            return "You are really into the tiles."
        case .intense:
            return "Long focused sessions in a row."
        }
    }
}

final class MoodEngine: ObservableObject {
    @Published private(set) var todaySeconds: TimeInterval = 0
    @Published private(set) var todaySessions: Int = 0
    @Published private(set) var activeMood: TableMood = .calm

    private let secondsKey = "mood.today.seconds"
    private let sessionsKey = "mood.today.sessions"
    private let dayKey = "mood.today.day"

    private let calendar = Calendar.current
    private var currentSessionStart: Date?

    init() {
        restoreFromStorage()
        refreshMood()
    }

    func startBoardSession() {
        let today = stripTime(Date())

        if let stored = UserDefaults.standard.object(forKey: dayKey) as? Date {
            let storedDay = stripTime(stored)
            if calendar.isDate(storedDay, inSameDayAs: today) == false {
                resetForNewDay(today: today)
            }
        } else {
            resetForNewDay(today: today)
        }

        if currentSessionStart == nil {
            currentSessionStart = Date()
            todaySessions += 1
            persist()
            refreshMood()
        }
    }

    func endBoardSession() {
        guard let start = currentSessionStart else { return }

        let now = Date()
        let delta = now.timeIntervalSince(start)
        if delta > 0 {
            todaySeconds += delta
        }

        currentSessionStart = nil
        persist()
        refreshMood()
    }

    func moodTitle() -> String {
        activeMood.title
    }

    func moodDetail() -> String {
        activeMood.detail
    }

    func resetAll() {
        todaySeconds = 0
        todaySessions = 0
        activeMood = .calm
        currentSessionStart = nil

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: secondsKey)
        defaults.removeObject(forKey: sessionsKey)
        defaults.removeObject(forKey: dayKey)
    }

    private func restoreFromStorage() {
        let defaults = UserDefaults.standard

        let storedSeconds = defaults.double(forKey: secondsKey)
        let storedSessions = defaults.integer(forKey: sessionsKey)
        let storedDay = defaults.object(forKey: dayKey) as? Date

        let today = stripTime(Date())

        if let day = storedDay {
            let strippedDay = stripTime(day)
            if calendar.isDate(strippedDay, inSameDayAs: today) {
                todaySeconds = storedSeconds
                todaySessions = storedSessions
            } else {
                resetForNewDay(today: today)
            }
        } else {
            resetForNewDay(today: today)
        }
    }

    private func resetForNewDay(today: Date) {
        todaySeconds = 0
        todaySessions = 0
        activeMood = .calm
        currentSessionStart = nil

        let defaults = UserDefaults.standard
        defaults.set(today, forKey: dayKey)
        defaults.set(todaySeconds, forKey: secondsKey)
        defaults.set(todaySessions, forKey: sessionsKey)
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(todaySeconds, forKey: secondsKey)
        defaults.set(todaySessions, forKey: sessionsKey)

        let today = stripTime(Date())
        defaults.set(today, forKey: dayKey)
    }

    private func refreshMood() {
        let minutes = todaySeconds / 60.0

        let mood: TableMood
        if minutes < 3 && todaySessions <= 2 {
            mood = .calm
        } else if minutes < 10 {
            mood = .focused
        } else if minutes < 25 {
            mood = .bright
        } else {
            mood = .intense
        }

        activeMood = mood
    }

    private func stripTime(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: comps) ?? date
    }
}
