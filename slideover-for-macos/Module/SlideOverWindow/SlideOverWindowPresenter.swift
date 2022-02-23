import Foundation

protocol SlideOverWindowPresenter {
    func fixWindow(type: SlideOverKind)
    func adjustWindow()
    func setInitialPage(url: URL?)
    func loadWebPage(url: URL?)
    func showHttpAlert()
    func showErrorAlert()
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
}
