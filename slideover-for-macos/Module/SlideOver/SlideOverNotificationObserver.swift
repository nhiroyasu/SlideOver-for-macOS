import Foundation
import Combine
import AppKit
import Injectable

class SlideOverNotificationObserver {
    private let action: SlideOverAction
    private let notificationManager: NotificationManager
    private let userSettingService: UserSettingService
    private let globalShortcutService: GlobalShortcutService
    
    var didMoveNotificationToken: AnyCancellable?
    var didDoubleRightClickNotificationToken: AnyCancellable?
    var willMoveNotificationToken: AnyCancellable?
    private var didLongRightClickNotificationToken: AnyCancellable?
    private let leftMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    private let rightMouseDownSubject = PassthroughSubject<NSEvent, Never>()
    private let rightMouseUpSubject = PassthroughSubject<NSEvent, Never>()
    
    init(injector: Injectable) {
        self.action = injector.build(SlideOverAction.self)
        self.notificationManager = injector.build(NotificationManager.self)
        self.userSettingService = injector.build(UserSettingService.self)
        self.globalShortcutService = injector.build(GlobalShortcutService.self)
        
        observeMouseEvent()
        setWillMoveNotification()
        setRightMouseUpSubject()
        observeReloadNotification()
        observeClearCacheNotification()
        observeHelpNotification()
        observeSearchFocusNotification()
        observeHideWindowNotification()
        registerSwitchWindowVisibilityShortcutKey()
        observeUrlOpenUrlNotification()
        observeZoomNotifications()
        observeDisplaySlideOverNotification()
    }
    
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
                self?.action.leftClickUpMouseButton()
            }
    }
    
    private func setRightMouseUpSubject() {
        didDoubleRightClickNotificationToken = rightMouseUpSubject
            .collect(.byTime(RunLoop.main, .milliseconds(600)))
            .filter { $0.count >= 2 }
            .sink { [weak self] _ in
                self?.action.doubleRightClickMouseButton()
            }
    }
    
    private func observeReloadNotification() {
        notificationManager.observe(name: .reload) { [weak self] _ in
            self?.action.reloadNotification()
        }
    }
    
    private func observeClearCacheNotification() {
        notificationManager.observe(name: .clearCache) { [weak self] _ in
            self?.action.cacheClearNotification()
        }
    }
    
    private func observeHelpNotification() {
        notificationManager.observe(name: .openHelp) { [weak self] _ in
            self?.action.openHelpNotification()
        }
    }
    
    private func observeSearchFocusNotification() {
        notificationManager.observe(name: .searchFocus) { [weak self] _ in
            self?.action.searchFocusNotification()
        }
    }
    
    private func observeHideWindowNotification() {
        notificationManager.observe(name: .hideWindow) { [weak self] _ in
            self?.action.hideWindowNotification()
        }
    }
    
    private func registerSwitchWindowVisibilityShortcutKey() {
        guard !userSettingService.isNotAllowedGlobalShortcut else { return }
        globalShortcutService.register(keyType: .command_control_s) { [weak self] in
            self?.action.switchWindowVisibilityShortcut()
        }
    }
    
    private func observeUrlOpenUrlNotification() {
        notificationManager.observe(name: .openUrl) { [weak self] urlValue in
            guard let urlStr = urlValue as? String,
                  let url = URL(string: urlStr) else { return }
            self?.action.openUrlNotification(url: url)
        }
    }
    
    private func observeZoomNotifications() {
        notificationManager.observe(name: .zoomInWebView) { [weak self] _ in
            self?.action.zoomInNotification()
        }
        
        notificationManager.observe(name: .zoomOutWebView) { [weak self] _ in
            self?.action.zoomOutNotification()
        }
        
        notificationManager.observe(name: .zoomResetWebView) { [weak self] _ in
            self?.action.zoomResetNotification()
        }
    }
    
    private func observeDisplaySlideOverNotification() {
        notificationManager.observe(name: .displaySlideOver) { [weak self] _ in
            self?.action.displayNotification()
        }
    }
}
