import Foundation
import QuartzCore

protocol SlideOverWindowPresenter {
    func fixWindow(type: SlideOverKind)
    func adjustWindow()
    func setInitialPage(url: URL?)
    func loadWebPage(url: URL?)
    func showHttpAlert()
    func showErrorAlert()
    func setProgress(value: Double)
    func reload()
    func setUserAgent(_ userAgent: UserAgent)
}

class SlideOverWindowPresenterImpl: SlideOverWindowPresenter {
    private var output: SlideOverWindowControllable? {
        injector.buildSafe(SlideOverWindowControllable.self)
    }
    private let alertService: AlertService
    private let slideOverService: SlideOverService
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
        self.alertService = injector.build(AlertService.self)
        self.slideOverService = injector.build(SlideOverService.self)
    }
    
    func fixWindow(type: SlideOverKind) {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.fixWindow(for: window, type: type)
        }
    }
    
    func adjustWindow() {
        output?.fixWindow { [weak self] window in
            guard let self = self, let window = window else { return }
            self.slideOverService.fixMovedWindow(for: window)
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
            self.alertService.alert(msg: "http://から始まるURLは開くことができません。\nhttps://から始まるURLを入力してください") {}
        }
    }
    
    func showErrorAlert() {
        DispatchQueue.main.async {
            self.alertService.alert(msg: "入力した値が有効ではありません") {}
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
            self.output?.webDisplayTypeItem.label = "スマホ表示"
        case .phone:
            self.output?.webDisplayTypeItem.image = NSImage(systemSymbolName: "laptopcomputer", accessibilityDescription: nil)
            self.output?.webDisplayTypeItem.label = "デスクトップ表示"
        }
    }
}
