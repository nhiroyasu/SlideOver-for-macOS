import Foundation
import QuartzCore

protocol SlideOverWindowPresenter {
    func fixWindow(type: SlideOverKind)
    func adjustWindow(isAppearAction: Bool)
    func reverseWindow()
    func setInitialPage(url: URL?)
    func loadWebPage(url: URL?)
    func showHttpAlert()
    func showErrorAlert()
    func setProgress(value: Double)
    func reload()
    func setUserAgent(_ userAgent: UserAgent)
    func setResizeHandler(handler: @escaping (NSSize, NSSize) -> (NSSize, SlideOverKind))
    func focusSearchBar()
    func applyTranslucentWindow()
    func resetTranslucentWindow()
    func disappearWindow()
    func appearWindow()
}

class SlideOverWindowPresenterImpl: SlideOverWindowPresenter {
    private var output: SlideOverWindowControllable? {
        injector.buildSafe(SlideOverWindowControllable.self)
    }
    private let alertService: AlertService
    private let slideOverService: SlideOverService
    private let userSetting :UserSettingService
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
        self.alertService = injector.build(AlertService.self)
        self.slideOverService = injector.build(SlideOverService.self)
        self.userSetting = injector.build(UserSettingService.self)
    }
    
    func fixWindow(type: SlideOverKind) {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.fixWindow(for: window, type: type)
        }
    }
    
    func adjustWindow(isAppearAction: Bool = false) {
        output?.contentView?.hideReappearLeftButton()
        output?.contentView?.hideReappearRightButton()
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.fixMovedWindow(for: window)
        }
    }
    
    func reverseWindow() {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.reverseMoveWindow(for: window)
        }
    }
    
    func setInitialPage(url: URL?) {
        output?.loadWebPage(url: url)
    }
    
    func loadWebPage(url: URL?) {
        output?.loadWebPage(url: url)
    }
    
    func showHttpAlert() {
        DispatchQueue.main.async {
            self.alertService.alert(msg: NSLocalizedString("URLs beginning with http:// cannot be opened.\nPlease enter a URL beginning with https://", comment: "")) {}
        }
    }
    
    func showErrorAlert() {
        DispatchQueue.main.async {
            self.alertService.alert(msg: NSLocalizedString("The entered value is not valid.", comment: "")) {}
        }
    }
    
    func setProgress(value: Double) {
        output?.progressBar?.layer?.opacity = 1.0
        output?.progressBar?.doubleValue = value
        if value == 100 {
            guard let layer = output?.progressBar?.layer else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = 0.8
                animation.fromValue = 1.0
                animation.toValue = 0.0
                animation.autoreverses = false
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                layer.add(animation, forKey: nil)
            }
        }
    }
    
    func reload() {
        output?.contentView?.browserReload()
    }
    
    func setUserAgent(_ userAgent: UserAgent) {
        self.output?.contentView?.webView.customUserAgent = userAgent.context
        self.output?.contentView?.webView.reloadFromOrigin()
        
        switch userAgent {
        case .desktop:
            self.output?.webDisplayTypeItem.image = NSImage(systemSymbolName: "iphone", accessibilityDescription: nil)
            self.output?.webDisplayTypeItem.label = NSLocalizedString("Mobile", comment: "")
        case .phone:
            self.output?.webDisplayTypeItem.image = NSImage(systemSymbolName: "laptopcomputer", accessibilityDescription: nil)
            self.output?.webDisplayTypeItem.label = NSLocalizedString("Desktop", comment: "")
        }
    }
    
    func setResizeHandler(handler: @escaping (NSSize, NSSize) -> (NSSize, SlideOverKind)) {
        var window = output
        window?.windowWillResizeHandler = { [weak self] currentWindow, next in
            let (nextSize, type) = handler(currentWindow.frame.size, next)
            self?.slideOverService.arrangeWindowPosition(for: currentWindow, size: nextSize, type: type)
            return nextSize
        }
    }
    
    func focusSearchBar() {
        output?.focusSearchBar()
    }
    
    func disappearWindow() {
        output?.fixWindow { [weak self] window in
            guard let window = window, let position = self?.userSetting.latestPosition else { return }
            self?.slideOverService.hideWindow(for: window, type: position)
            switch position {
            case .left, .topLeft, .bottomLeft:
                self?.output?.contentView?.hideReappearLeftButton()
                self?.output?.contentView?.showReappearRightButton()
            case .right, .topRight, .bottomRight:
                self?.output?.contentView?.hideReappearRightButton()
                self?.output?.contentView?.showReappearLeftButton()
            }
        }
    }
    
    func appearWindow() {
        guard let position = userSetting.latestPosition else { return }
        fixWindow(type: position)
        self.output?.contentView?.hideReappearLeftButton()
        self.output?.contentView?.hideReappearRightButton()
    }
    
    func applyTranslucentWindow() {
        output?.setWindowAlpha(0.0)
    }
    
    func resetTranslucentWindow() {
        output?.setWindowAlpha(1.0)
    }
}
