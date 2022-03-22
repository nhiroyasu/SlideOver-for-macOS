import Foundation
import AppKit
import Combine

protocol SlideOverWindowUseCase {
    func setUp()
    func loadWebPage(url: URL?)
    func searchGoogle(keyword: String)
    func registerInitialPage(url: URL?)
    func registerLatestPage(url: URL?)
    func registerLatestPositon(kind: SlideOverKind)
    func updateProgress(value progress: Double)
    func switchUserAgent()
}

class SlideOverWindowInteractor: SlideOverWindowUseCase {
    private var userSettingService: UserSettingService
    private var urlValidationService: URLValidationService
    private var urlEncodeService: URLEncodeService
    private let webViewService: WebViewService
    private let presenter: SlideOverWindowPresenter
    private let notificationManager: NotificationManager
    
    private var didMoveNotificationToken: AnyCancellable?
    private var didDoubleRightClickNotificationToken: AnyCancellable?
    private var willMoveNotificationToken: AnyCancellable?
    private let leftMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let rightMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let defaultInitialPage: URL? = URL(string: "https://google.com")
    private let helpUrl: URL? = URL(string: "https://nhiro.notion.site/On-the-Window-c330c5d9b23849afb4f80ad0a05cc568")
    private let defaultUserAgent: UserAgent = .desktop
    private let defaultSlideOverPosition: SlideOverKind = .right
    
    public init(injector: Injectable) {
        self.userSettingService = injector.build(UserSettingService.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        self.urlEncodeService = injector.build(URLEncodeService.self)
        self.webViewService = injector.build(WebViewService.self)
        self.presenter = injector.build(SlideOverWindowPresenter.self)
        self.notificationManager = injector.build(NotificationManager.self)
    }
    
    func setUp() {
        observeReloadNotification()
        observeClearCacheNotification()
        observeHelpNotification()
        observeMouseEvent()
        setWillMoveNotification()
        setRightMouseUpSubject()
        resizeWindow()
        
        if let latestPosition = userSettingService.latestPosition {
            presenter.fixWindow(type: latestPosition)
        } else {
            userSettingService.latestPosition = defaultSlideOverPosition
            presenter.fixWindow(type: defaultSlideOverPosition)
        }
        
        if let url = userSettingService.latestPage {
            presenter.setInitialPage(url: url)
        } else {
            presenter.setInitialPage(url: defaultInitialPage)
        }
        
        if let userAgent = userSettingService.latestUserAgent {
            presenter.setUserAgent(userAgent)
        } else {
            userSettingService.latestUserAgent = defaultUserAgent
            presenter.setUserAgent(defaultUserAgent)
        }
    }
    
    func loadWebPage(url: URL?) {
        presenter.loadWebPage(url: url)
    }
    
    func searchGoogle(keyword: String) {
        let encodedKeyword = urlEncodeService.encode(text: keyword)
        let urlString = "https://www.google.co.jp/search?q=\(encodedKeyword)"
        presenter.loadWebPage(url: URL(string: urlString))
    }
    
    func registerInitialPage(url: URL?) {
        userSettingService.initialPage = url
    }
    
    func registerLatestPage(url: URL?) {
        userSettingService.latestPage = url
    }
    
    func registerLatestPositon(kind: SlideOverKind) {
        userSettingService.latestPosition = kind
    }
    
    func updateProgress(value progress: Double) {
        presenter.setProgress(value: progress * 100)
    }
    
    func switchUserAgent() {
        let nextUserAgent: UserAgent
        guard let currentUserAgent = userSettingService.latestUserAgent else { return }
        switch currentUserAgent {
        case .desktop:
            nextUserAgent = .phone
        case .phone:
            nextUserAgent = .desktop
        }
        userSettingService.latestUserAgent = nextUserAgent
        presenter.setUserAgent(nextUserAgent)
    }
    
    private func resizeWindow() {
        presenter.setResizeHandler { [weak self] current, next in
            guard let currentPosition = self?.userSettingService.latestPosition else { return (next, .right) }
            return (currentPosition.state.computeResize(from: current, to: next), currentPosition)
        }
    }
}

extension SlideOverWindowInteractor {
    private func observeMouseEvent() {
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] event in
            self?.leftMouseUpSubject.send(event)
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: [.rightMouseUp]) { [weak self] event in
            self?.rightMouseUpSubject.send(event)
            return event
        }
    }
   
    private func setWillMoveNotification() {
        willMoveNotificationToken = NotificationCenter.default
            .publisher(for: NSWindow.willMoveNotification, object: nil)
            .sink { [weak self] notification in
                self?.setMoveNotification()
            }
    }

    private func setMoveNotification() {
        didMoveNotificationToken = leftMouseUpSubject
            .drop(untilOutputFrom: NotificationCenter.default.publisher(for: NSWindow.didMoveNotification, object: nil))
            .prefix(1)
            .sink { [weak self] event in
                self?.presenter.adjustWindow()
            }
    }
    
    private func setRightMouseUpSubject() {
        didDoubleRightClickNotificationToken = rightMouseUpSubject
            .collect(.byTime(RunLoop.current, .milliseconds(600)))
            .filter { $0.count >= 2 }
            .sink { [weak self] _ in
                self?.presenter.reverseWindow()
            }
    }
    
    private func observeReloadNotification() {
        notificationManager.observe(name: .reload) { [weak self] _ in
            self?.presenter.reload()
        }
    }
    
    private func observeClearCacheNotification() {
        notificationManager.observe(name: .clearCache) { [weak self] _ in
            self?.webViewService.clearCache()
            self?.presenter.reload()
        }
    }
    
    private func observeHelpNotification() {
        notificationManager.observe(name: .openHelp) { [weak self] _ in
            self?.presenter.loadWebPage(url: self?.helpUrl)
        }
    }
}
