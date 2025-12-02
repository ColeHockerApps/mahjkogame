import Combine
import SwiftUI

struct OnboardingScreen: View {
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var haptics: KoHaptics
    @EnvironmentObject private var daylight: DaylightEngine

    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            backgroundLayer
            GlowLayer().opacity(0.22)

            VStack(spacing: 24) {
                topBar
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                Spacer()

                slidesPager
                    .frame(maxWidth: 600, maxHeight: 380)
                    .padding(.horizontal, 24)

                indicators
                    .padding(.top, 8)

                controls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            daylight.refreshNow()
        }
        .onChange(of: vm.index) { _ in
            haptics.tapSoft()
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

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Text("MahjKo intro")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.45), radius: 6, x: 0, y: 3)

            Spacer()

            Text(daylight.phaseLabel())
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.14))
                )
                .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: Slides

    private var slidesPager: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 10)

            TabView(
                selection: Binding(
                    get: { vm.index },
                    set: { newValue in
                        let clamped = max(0, min(newValue, vm.slides.count - 1))
                        vm.index = clamped
                    }
                )
            ) {
                ForEach(vm.slides.indices, id: \.self) { idx in
                    slideView(for: vm.slides[idx])
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }

    private func slideView(for slide: OnboardingSlide) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                KoPalette.accent.opacity(0.35),
                                KoPalette.accentDeep.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 104, height: 104)
                    .shadow(color: KoPalette.accentDeep.opacity(0.9), radius: 18, x: 0, y: 10)

                Image(systemName: slide.symbol)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)

            Text(slide.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Text(slide.message)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .lineSpacing(3)

            Spacer(minLength: 0)
        }
        .padding(24)
    }

    // MARK: Indicators

    private var indicators: some View {
        HStack(spacing: 8) {
            ForEach(vm.slides.indices, id: \.self) { idx in
                Capsule()
                    .fill(idx == vm.index ? KoPalette.accentDeep : Color.white.opacity(0.35))
                    .frame(width: idx == vm.index ? 22 : 8, height: 8)
                    .animation(.easeOut(duration: 0.22), value: vm.index)
            }
        }
    }

    // MARK: Controls

    private var controls: some View {
        HStack(spacing: 14) {
            Button {
                haptics.tapSoft()
                if vm.index > 0 {
                    vm.goBack()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .opacity(vm.index == 0 ? 0.0 : 1.0)
            .disabled(vm.index == 0)

            Spacer()

            Button {
                haptics.tapSoft()
                vm.skip(flow: flow)
            } label: {
                Text("Skip")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.75))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Button {
                haptics.tapMedium()
                vm.goNext(flow: flow)
            } label: {
                HStack(spacing: 8) {
                    Text(vm.index == vm.slides.count - 1 ? "Start" : "Next")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: vm.index == vm.slides.count - 1 ? "play.fill" : "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [KoPalette.accent, KoPalette.accentDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: KoPalette.accentDeep.opacity(0.75), radius: 14, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
