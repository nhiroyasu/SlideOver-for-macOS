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
    func updateUserAgent(_ userAgent: UserAgent)
    func requestChangingPosition(type: SlideOverKind)
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
    private var didLongRightClickNotificationToken: AnyCancellable?
    private let leftMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let rightMouseDownSubject = PassthroughSubject<NSEvent, Never>()
    private let rightMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let defaultInitialPage: URL? = URL(string: "https://google.com")
    private let helpUrl: URL? = URL(string: "https://nhiro.notion.site/Fixture-in-Picture-0eef7a658b4b481a84fbc57d6e43a8f2")
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
        observeUrlOpenUrlNotification()
        observeHelpNotification()
        observeSearchFocusNotification()
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
    
    func updateUserAgent(_ userAgent: UserAgent) {
        userSettingService.latestUserAgent = userAgent
        presenter.setUserAgent(userAgent)
    }
    
    private func resizeWindow() {
        presenter.setResizeHandler { [weak self] current, next in
            guard let currentPosition = self?.userSettingService.latestPosition else { return (next, .right) }
            return (currentPosition.state.computeResize(from: current, to: next), currentPosition)
        }
    }
    
    func requestChangingPosition(type: SlideOverKind) {
        presenter.fixWindow(type: type)
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
        NSEvent.addLocalMonitorForEvents(matching: [.rightMouseDown]) { [weak self] event in
            self?.rightMouseDownSubject.send(event)
            return event
        }
        didLongRightClickNotificationToken = rightMouseDownSubject
            .flatMap { (event: NSEvent) in
                [event].publisher
                    .delay(for: 0.5, scheduler: RunLoop.main)
                    .prefix(untilOutputFrom: self.rightMouseUpSubject)
            }
            .flatMap { (event: NSEvent) -> Publishers.Output<PassthroughSubject<NSEvent, Never>> in
                self.presenter.applyTranslucentWindow()
                return self.rightMouseUpSubject
                    .prefix(1)
            }
            .sink { event in
                self.presenter.resetTranslucentWindow()
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
    
    private func observeSearchFocusNotification() {
        notificationManager.observe(name: .searchFocus) { [weak self] _ in
            self?.presenter.focusSearchBar()
        }
    }
    
    private func observeUrlOpenUrlNotification() {
        notificationManager.observe(name: .openUrl) { [weak self] urlValue in
            guard let urlStr = urlValue as? String,
                  let url = URL(string: urlStr) else { return }
            self?.presenter.loadWebPage(url: url)
        }
    }
}
