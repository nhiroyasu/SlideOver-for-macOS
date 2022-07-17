import Foundation
import Injectable

protocol SlideOverPresenter {
    func fix(at frame: NSRect)
    func fixWithDisappear(at frame: NSRect)
    func set(userAgent: UserAgent)
    func loadWebPage(url: URL?)
    func reloadWebPage()
    func openBrowser(url: URL?)
    func zoomIn()
    func zoomOut()
    func resetZoom()
    func focusSearchBar()
    func openSettingWindow()
}

class SlideOverPresenterImpl: SlideOverPresenter {
    
    private let state: SlideOverState
    private let applicationService: ApplicationService
    private var userSettingService: UserSettingService
    private let windowManager: WindowManager
    
    internal init(injector: Injectable = Injector.shared, state: SlideOverState) {
        self.state = state
        self.applicationService = injector.build(ApplicationService.self)
        self.userSettingService = injector.build()
        self.windowManager = injector.build()
    }
    
    func fix(at frame: NSRect) {
        // 順番依存
        state.isHidden = false
        state.frame = frame
        state.cacheFrame = frame
        userSettingService.latestWindowSize = frame.size
    }
    
    func fixWithDisappear(at frame: NSRect) {
        // 順番依存
        state.isHidden = true
        state.frame = frame
    }
    
    func set(userAgent: UserAgent) {
        state.userAgent = userAgent.rawValue
    }
    
    func loadWebPage(url: URL?) {
        state.url = url
        userSettingService.latestPage = url
    }
    
    func reloadWebPage() {
        state.reloadAction?()
    }
    
    func openBrowser(url: URL?) {
        guard let url = url else { return }
        applicationService.open(url)
    }
    
    func zoomIn() {
        state.zoom = state.zoom + 0.1
    }
    
    func zoomOut() {
        state.zoom = state.zoom - 0.1
    }
    
    func resetZoom() {
        state.zoom = 1.0
    }
    
    func focusSearchBar() {
        state.focusAction?()
    }
    
    func openSettingWindow() {
        windowManager.lunch(.setting)
    }
}
