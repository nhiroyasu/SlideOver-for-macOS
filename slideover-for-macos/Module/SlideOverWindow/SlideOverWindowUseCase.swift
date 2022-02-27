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
    
    struct State {
        var userAgent: UserAgent
    }
    
    private var userSettingService: UserSettingService
    private var urlValidationService: URLValidationService
    private var urlEncodeService: URLEncodeService
    private let presenter: SlideOverWindowPresenter
    private let notificationManager: NotificationManager
    
    private var didMoveNotificationToken: AnyCancellable?
    private var willMoveNotificationToken: AnyCancellable?
    private let leftMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let defaultInitialPage: URL? = URL(string: "https://google.com")
    private let defaultUserAgent: UserAgent = .desktop
    
    private var state: State
    
    public init(injector: Injectable) {
        self.userSettingService = injector.build(UserSettingService.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        self.urlEncodeService = injector.build(URLEncodeService.self)
        self.presenter = injector.build(SlideOverWindowPresenter.self)
        self.notificationManager = injector.build(NotificationManager.self)
        self.state = .init(userAgent: .desktop)
    }
    
    func setUp() {
        observeReloadNotification()
        observeMouseEvent()
        setWillMoveNotification()
        presenter.fixWindow(type: userSettingService.latestPosition ?? .right)
        
        if let url = userSettingService.latestPage {
            presenter.setInitialPage(url: url)
        } else {
            presenter.setInitialPage(url: defaultInitialPage)
        }
        
        if let userAgent = userSettingService.latestUserAgent {
            state.userAgent = userAgent
            presenter.setUserAgent(userAgent)
        } else {
            state.userAgent = defaultUserAgent
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
        switch state.userAgent {
        case .desktop:
            nextUserAgent = .phone
        case .phone:
            nextUserAgent = .desktop
        }
        state.userAgent = nextUserAgent
        userSettingService.latestUserAgent = nextUserAgent
        presenter.setUserAgent(nextUserAgent)
    }
}

extension SlideOverWindowInteractor {
    private func observeMouseEvent() {
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] event in
            self?.leftMouseUpSubject.send(event)
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
    
    private func observeReloadNotification() {
        notificationManager.observe(name: .reload) { [weak self] _ in
            self?.presenter.reload()
        }
    }
}
