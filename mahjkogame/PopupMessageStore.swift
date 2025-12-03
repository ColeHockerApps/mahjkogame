import Combine
import Foundation

struct PopupMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

final class PopupMessageStore {

    private let tips: [PopupMessage] = [
        .init(title: "Quick tip", body: "Look for tiles that open the widest space first."),
        .init(title: "Quick tip", body: "If three identical tiles appear, remove the pair that unlocks the most paths."),
        .init(title: "Quick tip", body: "Avoid clearing deep corners too early."),
        .init(title: "Quick tip", body: "Check both sides of long rows before matching.")
    ]

    private let facts: [PopupMessage] = [
        .init(title: "Mahjong fact", body: "The classic solitaire setup uses 144 tiles."),
        .init(title: "Mahjong fact", body: "Most layouts can be solved in multiple distinct ways."),
        .init(title: "Mahjong fact", body: "Tile families include circles, bamboos, characters, winds, and dragons."),
        .init(title: "Mahjong fact", body: "A tile is free when no tile touches its left or right side.")
    ]

    private let challenges: [PopupMessage] = [
        .init(title: "Today's challenge", body: "Finish one board today with fewer random taps."),
        .init(title: "Today's challenge", body: "Try a game where every move is planned for at least one second."),
        .init(title: "Today's challenge", body: "Spot two possible pairs before choosing one."),
        .init(title: "Today's challenge", body: "Play one round after training and compare the feeling.")
    ]

    func randomMessage() -> PopupMessage {
        let combined = tips + facts + challenges
        return combined.randomElement() ?? PopupMessage(title: "Welcome", body: "Enjoy your game today.")
    }
}
