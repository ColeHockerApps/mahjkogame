import Combine
import SwiftUI

struct TutorialGameScreen: View {

    @EnvironmentObject private var palette: KoPalette
    @EnvironmentObject private var flow: FlowLines
    @StateObject private var vm = TutorialGameViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 20) {
                topBar
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                Spacer(minLength: 8)

                headerText
                    .padding(.horizontal, 24)

                tilesGrid
                    .padding(.horizontal, 32)
                    .padding(.top, 6)

                Spacer(minLength: 8)

                footerHint
                    .padding(.horizontal, 24)
                    .padding(.bottom, 22)
            }

            if vm.showComplete {
                completionOverlay
            }
        }
        .animation(.easeOut(duration: 0.25), value: vm.currentStep)
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.02, green: 0.02, blue: 0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 40,
                endRadius: 420
            )
            .blendMode(.softLight)
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                flow.goHub()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Menu")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
            }

            Spacer()

            Text("Training")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.9))

            Spacer()
                .frame(width: 60)
        }
    }

    private var headerText: some View {
        VStack(spacing: 6) {
            Text(titleForStep(vm.currentStep))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.white)

            Text(subtitleForStep(vm.currentStep))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }

    private var tilesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(vm.tiles) { tile in
                tileCell(tile)
            }
        }
        .frame(maxWidth: 320)
    }

    private func tileCell(_ tile: TutorialTile) -> some View {
        let isHighlighted = vm.highlightHint.contains(tile.id)

        return Button {
            vm.selectTile(tile)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.16, green: 0.17, blue: 0.2),
                                Color(red: 0.11, green: 0.11, blue: 0.14)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                isHighlighted
                                ? KoPalette.accent
                                : Color.white.opacity(0.15),
                                lineWidth: isHighlighted ? 2.0 : 1.0
                            )
                    )
                    .shadow(
                        color: isHighlighted
                            ? KoPalette.accent.opacity(0.6)
                            : Color.black.opacity(0.8),
                        radius: isHighlighted ? 12 : 6,
                        x: 0,
                        y: isHighlighted ? 6 : 3
                    )

                Text(tile.symbol)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color.white)
                    .opacity(tile.matched ? 0.2 : 1.0)
                    .scaleEffect(tile.matched ? 0.8 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .disabled(tile.matched)
        .opacity(tile.matched ? 0.45 : 1.0)
        .animation(.easeOut(duration: 0.22), value: tile.matched)
    }

    private var footerHint: some View {
        Text(footerTextForStep(vm.currentStep))
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(Color.white.opacity(0.7))
            .multilineTextAlignment(.center)
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("You got it")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)

                Text("Now you know how matching feels. Ready for a full board?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Button {
                    vm.showComplete = false
                    flow.goBoard()
                } label: {
                    Text("Start full game")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.black)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(KoPalette.accent)
                        .cornerRadius(18)
                }

                Button {
                    vm.showComplete = false
                    flow.goHub()
                } label: {
                    Text("Back to menu")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.85))
                        .padding(.vertical, 8)
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 22)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.14))
            )
        }
        .transition(.opacity)
    }

    private func titleForStep(_ step: TutorialGameViewModel.Step) -> String {
        switch step {
        case .intro:
            return "Welcome to training"
        case .showPairs:
            return "Spot the pair"
        case .firstMatch:
            return "First match"
        case .secondMatch:
            return "Last pair"
        case .done:
            return "Nice work"
        }
    }

    private func subtitleForStep(_ step: TutorialGameViewModel.Step) -> String {
        switch step {
        case .intro:
            return "In this short training, you will remove pairs of tiles."
        case .showPairs:
            return "These two tiles match. Tap one of them to start the move."
        case .firstMatch:
            return "Now clear the next pair in the same way."
        case .secondMatch:
            return "Finish the board by removing the last matching pair."
        case .done:
            return "You are ready for a real layout."
        }
    }

    private func footerTextForStep(_ step: TutorialGameViewModel.Step) -> String {
        switch step {
        case .intro:
            return "Matching tiles with the same symbol removes them from the board."
        case .showPairs:
            return "Free tiles are the ones that are not blocked on both left and right sides."
        case .firstMatch:
            return "After a match, look at what new tiles became available."
        case .secondMatch:
            return "Every cleared pair opens more of the layout."
        case .done:
            return "Use the same focus when you play the full game."
        }
    }
}
