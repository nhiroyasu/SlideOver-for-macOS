import Foundation
import QuartzCore
import Injectable

/// @mockable
protocol SlideOverWindowPresenter {
    /// ウィンドウをtypeの位置に配置（サイズ,座標を修正）
    func fixWindow(type: SlideOverKind)
    /// ウィンドウをtypeの位置に移動（座標を修正、サイズはそのまま）
    func arrangeWindow(type: SlideOverKind)
    /// 初期表示用arrange
    func initialArrangeWindow(type: SlideOverKind, size: NSSize)
    /// ウィンドウをマウスの位置によって配置（サイズ,座標を修正）
    func fixWindowByMousePosition()
    func reverseWindow()
    func setInitialPage(url: URL?)
    func loadWebPage(url: URL?)
    func openBrowser(url: URL?)
    func showHttpAlert()
    func showErrorAlert()
    func setProgress(value: Double)
    func reload()
    func setUserAgent(_ userAgent: UserAgent)
    func setResizeHandler(handler: @escaping (NSSize, NSSize) -> (NSSize, SlideOverKind))
    func focusSearchBar()
    func applyTranslucentWindow()
    func resetTranslucentWindow()
    func disappearWindow(completion: @escaping (Bool) -> Void)
    func appearWindow(completion: @escaping (Bool) -> Void)
    func zoomIn()
    func zoomOut()
    func resetZoom()
}

class SlideOverWindowPresenterImpl: SlideOverWindowPresenter {
    private var output: SlideOverWindowControllable? {
        injector.buildSafe(SlideOverWindowControllable.self)
    }
    private let alertService: AlertService
    private let slideOverService: SlideOverService
    private let userSetting :UserSettingService
    private let applicationService: ApplicationService
    private let uiQueue: UIQueue
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
        self.alertService = injector.build(AlertService.self)
        self.slideOverService = injector.build(SlideOverService.self)
        self.userSetting = injector.build(UserSettingService.self)
        self.applicationService = injector.build(ApplicationService.self)
        self.uiQueue = injector.build(UIQueue.self)
    }
    
    func fixWindow(type: SlideOverKind) {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.fixWindow(for: window, type: type)
        }
    }
    
    func fixWindowByMousePosition() {
        restoreHiddenWindow()
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.fixMovedWindow(for: window)
        }
    }
    
    func arrangeWindow(type: SlideOverKind) {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.arrangeWindow(for: window, type: type)
        }
    }
    
    func initialArrangeWindow(type: SlideOverKind, size: NSSize) {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.arrangeWindow(for: window, windowSize: size, type: type)
        }
    }
    
    func reverseWindow() {
        restoreHiddenWindow()
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.reverseMoveWindow(for: window)
        }
    }
    
    func setInitialPage(url: URL?) {
        output?.loadWebPage(url: url)
    }
    
    func loadWebPage(url: URL?) {
        guard let url = url else { return }
        output?.loadWebPage(url: url)
    }
    
    func openBrowser(url: URL?) {
        guard let url = url else { return }
        applicationService.open(url)
    }
    
    func showHttpAlert() {
        uiQueue.mainAsync {
            self.alertService.alert(msg: NSLocalizedString("URLs beginning with http:// cannot be opened.\nPlease enter a URL beginning with https://", comment: "")) {}
        }
    }
    
    func showErrorAlert() {
        uiQueue.mainAsync {
            self.alertService.alert(msg: NSLocalizedString("The entered value is not valid.", comment: "")) {}
        }
    }
    
    func setProgress(value: Double) {
        output?.progressBar?.layer?.opacity = 1.0
        output?.progressBar?.doubleValue = value
        if value == 100 {
            guard let layer = output?.progressBar?.layer else { return }
            uiQueue.mainAsyncAfter(deadline: .now() + 0.8) {
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
    }
    
    func setResizeHandler(handler: @escaping (NSSize, NSSize) -> (NSSize, SlideOverKind)) {
//        var window = output
//        window?.windowWillResizeHandler = { [weak self] currentWindow, next in
//            let (nextSize, type) = handler(currentWindow.frame.size, next)
//            self?.slideOverService.arrangeWindowPosition(for: currentWindow, windowSize: nextSize, type: type)
//            return nextSize
//        }
    }
    
    func focusSearchBar() {
        output?.focusSearchBar()
    }
    
    private var windowSizeBeforeHideCompletely: NSSize?
    func disappearWindow(completion: @escaping (Bool) -> Void) {
        guard let output = output, !output.isMiniaturized else {
            completion(false)
            return
        }
        
        output.fixWindow { [weak self] window in
            guard let self = self, let window = window, let position = self.userSetting.latestPosition else {
                completion(false)
                return
            }
            
            if self.userSetting.hiddenActionIsMiniaturized {
                self.windowSizeBeforeHideCompletely = window.frame.size
                let isSuccess = self.slideOverService.hideWindowCompletely(for: window, type: position)
                NSApplication.shared.hide(nil)
                completion(isSuccess)
            } else {
                let isSuccess = self.slideOverService.hideWindowOnlyHalf(for: window, type: position)
                if isSuccess {
                    switch position {
                    case .left, .topLeft, .bottomLeft:
                        self.output?.contentView?.hideReappearLeftButton(completion: {})
                        self.output?.contentView?.showReappearRightButton(completion: { [weak self] in
                            self?.output?.setWindowAlpha(0.4)
                        })
                    case .right, .topRight, .bottomRight:
                        self.output?.contentView?.hideReappearRightButton(completion: {})
                        self.output?.contentView?.showReappearLeftButton(completion: { [weak self] in
                            self?.output?.setWindowAlpha(0.4)
                        })
                    }
                }
                completion(isSuccess)
            }
        }
      
    }
    
    func appearWindow(completion: @escaping (Bool) -> Void) {
        guard let position = userSetting.latestPosition,
              let output = output,
              !output.isMiniaturized else {
            completion(false)
            return
        }
        
        output.fixWindow { [weak self] window in
            guard let self = self, let window = window else {
                completion(false)
                return
            }
            
            if self.userSetting.hiddenActionIsMiniaturized {
                NSApplication.shared.unhide(nil)
                if let windowSize = self.windowSizeBeforeHideCompletely {
                    self.slideOverService.arrangeWindow(for: window, windowSize: windowSize, type: position)
                    self.windowSizeBeforeHideCompletely = nil
                }
            } else {
                self.slideOverService.arrangeWindow(for: window, type: position)
            }
            self.restoreHiddenWindow()
            completion(true)
        }
    }
    
    func applyTranslucentWindow() {
        output?.setWindowAlpha(0.0)
    }
    
    func resetTranslucentWindow() {
        output?.setWindowAlpha(1.0)
    }
    
    private func restoreHiddenWindow() {
        output?.setWindowAlpha(1.0)
        self.output?.contentView?.hideReappearLeftButton(completion: {})
        self.output?.contentView?.hideReappearRightButton(completion: {})
    }
    
    func zoomIn() {
        guard let webView = output?.contentView?.webView else { return }
        webView.setMagnification(webView.magnification + 0.1, centeredAt: .zero)
    }
    
    func zoomOut() {
        guard let webView = output?.contentView?.webView else { return }
        webView.setMagnification(webView.magnification - 0.1, centeredAt: .zero)
    }
    
    func resetZoom() {
        guard let webView = output?.contentView?.webView else { return }
        webView.setMagnification(1.0, centeredAt: .zero)
    }
}
