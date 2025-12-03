import Foundation
import SwiftUI
import Combine

final class TutorialGameViewModel: ObservableObject {

    enum Step: Int {
        case intro = 0
        case showPairs
        case firstMatch
        case secondMatch
        case done
    }

    @Published var tiles: [TutorialTile] = []
    @Published var highlightHint: [UUID] = []
    @Published var showComplete = false
    @Published var currentStep: Step = .intro

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadInitial()
    }

    private func loadInitial() {
        tiles = [
            TutorialTile(id: UUID(), symbol: "🐉", matched: false, group: 1),
            TutorialTile(id: UUID(), symbol: "🐉", matched: false, group: 1),
            TutorialTile(id: UUID(), symbol: "🔥", matched: false, group: 2),
            TutorialTile(id: UUID(), symbol: "🔥", matched: false, group: 2)
        ].shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.advance(to: .showPairs)
        }
    }

    func advance(to step: Step) {
        currentStep = step

        switch step {
        case .intro:
            highlightHint = []

        case .showPairs:
            highlightHint = tiles
                .filter { $0.group == 1 }
                .map { $0.id }

        case .firstMatch:
            highlightHint = []

        case .secondMatch:
            highlightHint = tiles
                .filter { !$0.matched }
                .map { $0.id }

        case .done:
            highlightHint = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showComplete = true
            }
        }
    }

    func selectTile(_ tile: TutorialTile) {
        guard !tile.matched else { return }

        switch currentStep {

        case .showPairs:
            match(group: 1)
            advance(to: .firstMatch)

        case .firstMatch:
            match(group: 2)
            advance(to: .secondMatch)

        case .secondMatch:
            finishTutorial()

        case .intro, .done:
            break
        }
    }

    private func match(group: Int) {
        for idx in tiles.indices {
            if tiles[idx].group == group {
                tiles[idx].matched = true
            }
        }
    }

    private func finishTutorial() {
        advance(to: .done)
    }
}

struct TutorialTile: Identifiable, Equatable {
    let id: UUID
    let symbol: String
    var matched: Bool
    let group: Int
}
