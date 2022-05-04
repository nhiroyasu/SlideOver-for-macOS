import Foundation
protocol SlideOverWindowAction {
    func showWindow()
    func inputSearchBar(input: String)
    func didTapInitialPageItem(currentUrl url: URL?)
    func didChangePage(url: URL?)
    func didChangePosition(kind: SlideOverKind)
    func didUpdateProgress(value: Double)
    func didTapDisplayType()
    func didTapChangingPositionButton(type: SlideOverKind)
    func didTapUpdateUserAgent(_ userAgent: UserAgent)
    func didTapHideWindow()
}

class SlideOverWindowActionImpl: SlideOverWindowAction {
    
    private let useCase: SlideOverWindowUseCase
    private let urlValidationService: URLValidationService
    
    init(injector: Injectable) {
        self.useCase = injector.build(SlideOverWindowUseCase.self)
        self.urlValidationService = injector.build(URLValidationService.self)
    }
    
    func showWindow() {
        useCase.setUp()
    }
    
    func inputSearchBar(input: String) {
        if urlValidationService.isUrl(text: input) {
            useCase.loadWebPage(url: URL(string: input))
        } else {
            useCase.searchGoogle(keyword: input)
        }
    }
    
    func didTapInitialPageItem(currentUrl url: URL?) {
        useCase.registerInitialPage(url: url)
    }
    
    func didChangePage(url: URL?) {
        useCase.registerLatestPage(url: url)
    }
    
    func didChangePosition(kind: SlideOverKind) {
        useCase.registerLatestPositon(kind: kind)
    }
    
    func didUpdateProgress(value: Double) {
        useCase.updateProgress(value: value)
    }
    
    func didTapDisplayType() {
        useCase.switchUserAgent()
    }
    
    func didTapChangingPositionButton(type: SlideOverKind) {
        useCase.requestChangingPosition(type: type)
    }
    
    func didTapUpdateUserAgent(_ userAgent: UserAgent) {
        useCase.updateUserAgent(userAgent)
    }
    
    func didTapHideWindow() {
        useCase.hideWindow()
    }
}
