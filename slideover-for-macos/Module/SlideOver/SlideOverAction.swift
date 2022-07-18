import Foundation
import Injectable

protocol SlideOverAction {
    // view
    func showWindow()
    func windowWillClose(size: NSSize?)
    func windowDidEndLiveResize(_ frame: NSRect)
    func didEnterSearchBar(input: String)
    func didTapChangingPositionButton(type: SlideOverKind)
    func didTapUpdateUserAgent(_ userAgent: UserAgent)
    func didTapHideWindow()
    func didTapHelp()
    func didTapSetting()
    func didTapReappearButton()
    // menu
    func didTapWindowLayoutForRightMenuItem()
    func didTapWindowLayoutForLeftMenuItem()
    func didTapWindowLayoutForRightTopMenuItem()
    func didTapWindowLayoutForRightBottomMenuItem()
    func didTapWindowLayoutForLeftTopMenuItem()
    func didTapWindowLayoutForLeftBottomMenuItem()
    func didTapUserAgentForMobileMenuItem()
    func didTapUserAgentForDesktopMenuItem()
    func didTapHideWindowMenuItem()
    func didTapHelpMenuItem()
    func didTapSettingMenuItem()
    // notification
    func leftClickUpMouseButton()
    func doubleRightClickMouseButton()
    func reloadNotification()
    func cacheClearNotification()
    func openHelpNotification()
    func searchFocusNotification()
    func hideWindowNotification()
    func displayNotification()
    func switchWindowVisibilityShortcut()
    func openUrlNotification(url: URL)
    func zoomInNotification()
    func zoomOutNotification()
    func zoomResetNotification()
}

class SlideOverActionImpl: SlideOverAction {
    
    private let useCase: SlideOverUseCase
    private let urlValidationService: URLValidationService
    private let state: SlideOverState
    
    public init(injector: Injectable = Injector.shared, state: SlideOverState) {
        self.useCase = injector.build(SlideOverUseCase.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        self.state = state
    }
    
    func showWindow() {
        useCase.setUp()
    }
    
    func didEnterSearchBar(input: String) {
        if urlValidationService.isUrl(text: input) {
            useCase.load(url: URL(string: input))
        } else {
            useCase.searchGoogle(keyword: input)
        }
    }
    
    func didTapChangingPositionButton(type: SlideOverKind) {
        useCase.requestChangingPosition(type: type)
    }
    
    func didTapUpdateUserAgent(_ userAgent: UserAgent) {
        useCase.updateUserAgent(userAgent)
    }
    
    func didTapHideWindow() {
        useCase.disappear(for: ObjectFrame(from: state.cacheFrame))
    }
    
    func didTapHelp() {
        useCase.showHelp()
    }
    
    func didTapSetting() {
        useCase.showSetting()
    }
    
    func didTapReappearButton() {
        useCase.appear(for: ObjectFrame(from: state.cacheFrame))
    }
    
    func windowWillClose(size: NSSize?) {
        useCase.memorizeLatestWindowSize(size)
    }

    func windowDidEndLiveResize(_ frame: NSRect) {
        if !state.isHidden {
            useCase.requestResize(nextFrame: ObjectFrame(from: frame))
        }
    }
    
    func leftClickUpMouseButton() {
        useCase.replace()
    }
    
    func doubleRightClickMouseButton() {
        useCase.reversePosition()
    }
    
    func reloadNotification() {
        useCase.reload()
    }
    
    func cacheClearNotification() {
        useCase.clearCache()
    }
    
    func openHelpNotification() {
        useCase.showHelp()
    }
    
    func searchFocusNotification() {
        useCase.focusSearchBar()
    }
    
    func hideWindowNotification() {
        useCase.disappear(for: ObjectFrame(from: state.cacheFrame))
    }
    
    func displayNotification() {
        useCase.appear(for: ObjectFrame(from: state.cacheFrame))
    }
    
    func switchWindowVisibilityShortcut() {
        if state.isHidden {
            useCase.appear(for: ObjectFrame(from: state.cacheFrame))
        } else {
            useCase.disappear(for: ObjectFrame(from: state.cacheFrame))
        }
    }
    
    func openUrlNotification(url: URL) {
        useCase.load(url: url)
    }
    
    func zoomInNotification() {
        useCase.zoomIn()
    }
    
    func zoomOutNotification() {
        useCase.zoomOut()
    }
    
    func zoomResetNotification() {
        useCase.zoomReset()
    }
    
    func didTapWindowLayoutForRightMenuItem() {
        useCase.requestChangingPosition(type: .right)
    }
    
    func didTapWindowLayoutForLeftMenuItem() {
        useCase.requestChangingPosition(type: .left)
    }
    
    func didTapWindowLayoutForRightTopMenuItem() {
        useCase.requestChangingPosition(type: .topRight)
    }
    
    func didTapWindowLayoutForRightBottomMenuItem() {
        useCase.requestChangingPosition(type: .bottomRight)
    }
    
    func didTapWindowLayoutForLeftTopMenuItem() {
        useCase.requestChangingPosition(type: .topLeft)
    }
    
    func didTapWindowLayoutForLeftBottomMenuItem() {
        useCase.requestChangingPosition(type: .bottomLeft)
    }
    
    func didTapUserAgentForMobileMenuItem() {
        useCase.updateUserAgent(.phone)
    }
    
    func didTapUserAgentForDesktopMenuItem() {
        useCase.updateUserAgent(.desktop)
    }
    
    func didTapHideWindowMenuItem() {
        useCase.disappear(for: ObjectFrame(from: state.cacheFrame))
    }
    
    func didTapHelpMenuItem() {
        useCase.showHelp()
    }
    
    func didTapSettingMenuItem() {
        useCase.showSetting()
    }
}
