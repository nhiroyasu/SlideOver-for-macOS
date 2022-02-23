import Foundation
protocol SlideOverWindowAction {
    func showWindow()
    func didTapInitialPageItem(currentUrl url: URL?)
}

class SlideOverWindowActionImpl: SlideOverWindowAction {
    
    private let useCase: SlideOverWindowUseCase
    
    init(injector: Injectable) {
        self.useCase = injector.build(SlideOverWindowUseCase.self)
    }
    
    func showWindow() {
        useCase.setUp()
    }
    
    func didTapInitialPageItem(currentUrl url: URL?) {
        useCase.registerInitialPage(url: url)
    }
}
