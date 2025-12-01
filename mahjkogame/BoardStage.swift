import Combine
import SwiftUI
import WebKit

struct BoardStage: View {
    @EnvironmentObject private var theme: KoTheme
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var ledger: PathLedger
    @StateObject private var vm = BoardViewModel()

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    BoardHost(
                        entry: ledger.restoreStoredTrail() ?? ledger.mainEntry,
                        ledger: ledger
                    ) {
                        vm.markReady()
                    }
                    .opacity(vm.fadeIn ? 1 : 0)
                    .animation(.easeOut(duration: 0.3), value: vm.fadeIn)

                    if vm.isReady == false {
                        loadingOverlay
                    }
                }
            }

            Color.black
                .opacity(vm.dimLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: vm.dimLayer)
        }
        .onAppear {
            vm.onAppear()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                vm.close(flow: flow)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: KoIcons.back)
                        .font(.system(size: 16, weight: .semibold))

                    Text("Menu")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(KoPalette.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(KoPalette.card)
                        .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 4)
                )
            }

            Spacer()
        }
        .padding(.top, 18)
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
        .background(
            Color.black.opacity(0.9)
                .ignoresSafeArea(edges: .top)
        )
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)

                Text("Loading board…")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(KoPalette.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(KoPalette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(KoPalette.borderSoft, lineWidth: 1)
                    )
                    .shadow(color: KoPalette.softShadow, radius: 10, x: 0, y: 6)
            )
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.25), value: vm.isReady)
    }
}

// MARK: - ViewModel

final class BoardViewModel: ObservableObject {
    @Published var isReady: Bool = false
    @Published var fadeIn: Bool = false
    @Published var dimLayer: Double = 0.0

    func onAppear() {
        withAnimation(.easeOut(duration: 0.35)) {
            fadeIn = true
            dimLayer = 0.35
        }
    }

    func markReady() {
        withAnimation(.easeOut(duration: 0.25)) {
            isReady = true
            dimLayer = 0.0
        }
    }

    func close(flow: FlowLines) {
        KoHaptics.shared.tapSoft()
        flow.closeCurrent()
    }
}

// MARK: - Web host

struct BoardHost: UIViewRepresentable {
    let entry: URL
    let ledger: PathLedger
    let onReady: () -> Void

    func makeCoordinator() -> BoardGuide {
        BoardGuide(entry: entry, ledger: ledger, onReady: onReady)
    }

    func makeUIView(context: Context) -> WKWebView {
        let board = WKWebView(frame: .zero)

        board.navigationDelegate = context.coordinator
        board.uiDelegate = context.coordinator

        board.allowsBackForwardNavigationGestures = true
        board.scrollView.bounces = true
        board.scrollView.showsVerticalScrollIndicator = false
        board.scrollView.showsHorizontalScrollIndicator = false
        board.isOpaque = false
        board.backgroundColor = .black
        board.scrollView.backgroundColor = .black

        let refresh = UIRefreshControl()
        refresh.addTarget(
            context.coordinator,
            action: #selector(BoardGuide.handleRefresh(_:)),
            for: .valueChanged
        )
        board.scrollView.refreshControl = refresh

        context.coordinator.attach(board)
        context.coordinator.beginBoard()

        return board
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

final class BoardGuide: NSObject, WKNavigationDelegate, WKUIDelegate {
    private let entry: URL
    private let ledger: PathLedger
    private let onReady: () -> Void

    weak var mainBoard: WKWebView?
    weak var popupBoard: WKWebView?

    private var baseHost: String?
    private var marksTimer: Timer?

    init(entry: URL, ledger: PathLedger, onReady: @escaping () -> Void) {
        self.entry = entry
        self.ledger = ledger
        self.onReady = onReady
        self.baseHost = entry.host?.lowercased()
    }

    func attach(_ board: WKWebView) {
        mainBoard = board
    }

    func beginBoard() {
        let request = URLRequest(url: entry)
        mainBoard?.load(request)
    }

    // MARK: - Refresh

    @objc func handleRefresh(_ sender: UIRefreshControl) {
        mainBoard?.reload()
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if webView === popupBoard {
            if let main = mainBoard,
               let link = navigationAction.request.url {
                main.load(URLRequest(url: link))
            }
            decisionHandler(.cancel)
            return
        }

        guard let link = navigationAction.request.url,
              let schemeName = link.scheme?.lowercased()
        else {
            decisionHandler(.cancel)
            return
        }

        let allowed = schemeName == "http"
            || schemeName == "https"
            || schemeName == "about"

        guard allowed else {
            decisionHandler(.cancel)
            return
        }

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        stopMarksJob()
    }

    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        handleFinish(in: webView)
    }

    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        handleFailure(in: webView)
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        handleFailure(in: webView)
    }

    private func handleFinish(in board: WKWebView) {
        onReady()
        board.scrollView.refreshControl?.endRefreshing()

        guard let current = board.url else {
            stopMarksJob()
            return
        }

        rememberTrailIfNeeded(current)

        let nowHost = current.host?.lowercased()
        let isBase: Bool
        if let base = baseHost, let now = nowHost, now == base {
            isBase = true
        } else {
            isBase = false
        }

        if isBase {
            stopMarksJob()
        } else {
            runMarksJob(for: current, in: board)
        }
    }

    private func handleFailure(in board: WKWebView) {
        onReady()
        board.scrollView.refreshControl?.endRefreshing()
        stopMarksJob()
    }

    // MARK: - WKUIDelegate

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        let popup = WKWebView(frame: .zero, configuration: configuration)
        popup.navigationDelegate = self
        popup.uiDelegate = self
        popupBoard = popup
        return popup
    }

    // MARK: - Trail memory

    private func rememberTrailIfNeeded(_ entryPoint: URL) {
        let startString = entry.absoluteString
        let currentString = entryPoint.absoluteString
        guard currentString != startString else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            self.ledger.storeTrailIfNeeded(entryPoint)
        }
    }

    // MARK: - Marks job

    private func runMarksJob(for entryPoint: URL, in board: WKWebView) {
        stopMarksJob()

        let mask = (entryPoint.host ?? "").lowercased()

        marksTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {
            [weak board, weak ledger] _ in
            guard let view = board, let store = ledger else { return }

            view.configuration.websiteDataStore.httpCookieStore.getAllCookies { list in
                let filtered = list.filter { cookie in
                    guard !mask.isEmpty else { return true }
                    return cookie.domain.lowercased().contains(mask)
                }

                let packed: [[String: Any]] = filtered.map { c in
                    var map: [String: Any] = [
                        "name": c.name,
                        "value": c.value,
                        "domain": c.domain,
                        "path": c.path,
                        "secure": c.isSecure,
                        "httpOnly": c.isHTTPOnly
                    ]
                    if let exp = c.expiresDate {
                        map["expires"] = exp.timeIntervalSince1970
                    }
                    if #available(iOS 13.0, *), let s = c.sameSitePolicy {
                        map["sameSite"] = s.rawValue
                    }
                    return map
                }

                store.saveMarks(packed)
            }
        }

        if let job = marksTimer {
            RunLoop.main.add(job, forMode: .common)
        }
    }

    private func stopMarksJob() {
        marksTimer?.invalidate()
        marksTimer = nil
    }
}
