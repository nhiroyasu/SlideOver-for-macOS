import Foundation

protocol SlideOverWindowPresenter {
    func fixWindow(type: SlideOverKind)
    func adjustWindow()
    func setInitialPage(url: URL?)
}

class SlideOverWindowPresenterImpl: SlideOverWindowPresenter {
    private var output: SlideOverWindowControllable? {
        injector.buildSafe(SlideOverWindowControllable.self)
    }
    private let slideOverService: SlideOverService
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
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
}
