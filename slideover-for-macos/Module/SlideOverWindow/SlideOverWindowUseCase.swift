import Foundation
import AppKit
import Combine

protocol SlideOverWindowUseCase {
    func setUp()
    func loadWebPage(url: URL?)
    func registerInitialPage(url: URL?)
}

class SlideOverWindowInteractor: SlideOverWindowUseCase {
    
    private var userSettingService: UserSettingService
    private var urlValidationService: URLValidationService
    private let presenter: SlideOverWindowPresenter
    
    private var didMoveNotificationToken: AnyCancellable?
    private var willMoveNotificationToken: AnyCancellable?
    private let leftMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let defaultInitialPage: URL? = URL(string: "https://google.com")
    
    public init(injector: Injectable) {
        self.userSettingService = injector.build(UserSettingService.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        self.presenter = injector.build(SlideOverWindowPresenter.self)
    }
    
    func setUp() {
        observeMouseEvent()
        setWillMoveNotification()
        presenter.fixWindow(type: .right)
        
        if let url = userSettingService.initialPage {
            presenter.setInitialPage(url: url)
        } else {
            presenter.setInitialPage(url: defaultInitialPage)
        }
    }
    
    func loadWebPage(url: URL?) {
        presenter.loadWebPage(url: url)
    }
    
    func registerInitialPage(url: URL?) {
        userSettingService.initialPage = url
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
}
