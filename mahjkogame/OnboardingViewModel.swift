import Combine
import SwiftUI

struct OnboardingSlide: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let symbol: String
}

final class OnboardingViewModel: ObservableObject {
    @Published private(set) var slides: [OnboardingSlide] = []
    @Published var index: Int = 0
    @Published private(set) var finished: Bool = false

    var currentSlide: OnboardingSlide {
        guard slides.indices.contains(index) else {
            return slides.first ?? OnboardingSlide(
                title: "",
                message: "",
                symbol: "square"
            )
        }
        return slides[index]
    }

    init() {
        buildSlides()
    }

    func goNext(flow: FlowLines) {
        guard index < slides.count - 1 else {
            complete(flow: flow)
            return
        }
        index += 1
    }

    func goBack() {
        guard index > 0 else { return }
        index -= 1
    }

    func skip(flow: FlowLines) {
        complete(flow: flow)
    }

    func reset() {
        index = 0
        finished = false
    }

    private func complete(flow: FlowLines) {
        finished = true
        flow.finishOnboarding()
    }

    private func buildSlides() {
        slides = [
            OnboardingSlide(
                title: "Welcome to MahjKo",
                message: "A calm way to enjoy tile boards without rush or pressure.",
                symbol: "sparkles"
            ),
            OnboardingSlide(
                title: "Daily streak",
                message: "Come back every day and keep your streak growing on the main screen.",
                symbol: "flame"
            ),
            OnboardingSlide(
                title: "Table mood",
                message: "MahjKo tracks how long you play and reflects your daily table mood.",
                symbol: "face.smiling"
            ),
            OnboardingSlide(
                title: "Tiny quests",
                message: "Complete small daily goals like starting boards or keeping calm minutes.",
                symbol: "checkmark.circle"
            )
        ]
    }
}
