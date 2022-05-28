import Foundation
import XCTest
@testable import Fixture_in_Picture
import Swinject

class SlideOverWindowPresenterTests: XCTestCase {
    
    var subject: SlideOverWindowPresenterImpl!
    var alertService: AlertServiceMock!
    var slideOverService: SlideOverServiceMock!
    var userSetting :UserSettingServiceMock!
    var applicationService: ApplicationServiceMock!
    var output: SlideOverWindowControllableMock!
    var contentView: SlideOverViewableMock!
    var uiQueue: UIQueueMock!
    
    override func setUp() {
        super.setUp()
        
        alertService = .init()
        slideOverService = .init()
        userSetting = .init()
        applicationService = .init()
        contentView = .init()
        output = .init()
        output.fixWindowHandler = { $0(NSWindow()) }
        output.contentView = contentView
        uiQueue = .init()
        uiQueue.mainAsyncHandler = { $0() }
        uiQueue.mainAsyncAfterHandler = { $1() }
        
        let container = Container()
        container.register(AlertService.self, impl: alertService)
        container.register(SlideOverService.self, impl: slideOverService)
        container.register(UserSettingService.self, impl: userSetting)
        container.register(ApplicationService.self, impl: applicationService)
        container.register(SlideOverWindowControllable.self, impl: output)
        container.register(UIQueue.self, impl: uiQueue)
        let injector = TestInjector(container: container)
        subject = .init(injector: injector)
    }
    
    func test_fixWindow() {
        subject.fixWindow(type: .right)
        
        XCTAssertEqual(output.fixWindowCallCount, 1)
        XCTAssertEqual(slideOverService.fixWindowCallCount, 1)
    }
    
    func test_adjustWindow() {
        subject.adjustWindow()
        
        XCTAssertEqual(output.setWindowAlphaCallCount, 1)
        XCTAssertEqual(output.setWindowAlphaArgValues.first, 1.0)
        XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 1)
        XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 1)
        XCTAssertEqual(output.fixWindowCallCount, 1)
        XCTAssertEqual(slideOverService.fixMovedWindowCallCount, 1)
    }
    
    func test_reverseWindow() {
        subject.reverseWindow()
        
        XCTAssertEqual(output.setWindowAlphaCallCount, 1)
        XCTAssertEqual(output.setWindowAlphaArgValues.first, 1.0)
        XCTAssertEqual(output.fixWindowCallCount, 1)
        XCTAssertEqual(slideOverService.reverseMoveWindowCallCount, 1)
    }
    
    func test_setInitialPage() {
        subject.setInitialPage(url: .stubUrl)
        
        XCTAssertEqual(output.loadWebPageCallCount, 1)
        XCTAssertEqual(output.loadWebPageArgValues.first, .stubUrl)
    }
    
    func test_loadWebPage() {
        subject.loadWebPage(url: .stubUrl)
        
        XCTAssertEqual(applicationService.openCallCount, 1)
        XCTAssertEqual(applicationService.openArgValues.first, .stubUrl)
    }
    
    func test_showHttpAlert() {
        subject.showHttpAlert()
        
        XCTAssertEqual(alertService.alertCallCount, 1)
    }
    
    func test_showErrorAlert() {
        subject.showErrorAlert()
        
        XCTAssertEqual(alertService.alertCallCount, 1)
    }
    
    func test_setProgress() {
    }
    
    func test_reload() {
        subject.reload()
        
        XCTAssertEqual(contentView.browserReloadCallCount, 1)
    }
    
    func test_setUserAgent() {
    }
    
    func test_setResizeHandler() {
        var callCount = 0
        subject.setResizeHandler { _, _ in
            callCount += 1
            return (NSSize(width: 0, height: 0), .right)
        }
        let _ = output.windowWillResizeHandler!(NSWindow(), .init(width: 0, height: 0))
        
        XCTAssertEqual(slideOverService.arrangeWindowPositionCallCount, 1)
        XCTAssertEqual(callCount, 1)
    }
    
    func test_focusSearchBar() {
        subject.focusSearchBar()
        
        XCTAssertEqual(output.focusSearchBarCallCount, 1)
    }
    
    func test_applyTranslucentWindow() {
        subject.applyTranslucentWindow()
        
        XCTAssertEqual(output.setWindowAlphaCallCount, 1)
        XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.0)
    }
    
    func test_resetTranslucentWindow() {
        subject.resetTranslucentWindow()
        
        XCTAssertEqual(output.setWindowAlphaCallCount, 1)
        XCTAssertEqual(output.setWindowAlphaArgValues.first, 1.0)
    }
    
    func test_disappearWindow() {
        XCTContext.runActivity(named: "ポジションがright側のとき") { _ in
            XCTContext.runActivity(named: "right") { _ in
                setUp()
                userSetting.latestPosition = .right
                slideOverService.hideWindowHandler = { _, _ in true }
                output.isMiniaturized = false

                contentView.showReappearLeftButtonHandler = { $0() }
                var isSuccess: Bool?
                subject.disappearWindow { isSuccess = $0 }
                
                XCTAssertEqual(output.fixWindowCallCount, 1)
                XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
                XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 1)
                XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 1)
                XCTAssertEqual(contentView.showReappearRightButtonCallCount, 0)
                XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 0)
                XCTAssertEqual(output.setWindowAlphaCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.4)
                XCTAssertEqual(isSuccess, true)
            }
            XCTContext.runActivity(named: "topRight") { _ in
                setUp()
                userSetting.latestPosition = .topRight
                slideOverService.hideWindowHandler = { _, _ in true }
                output.isMiniaturized = false

                contentView.showReappearLeftButtonHandler = { $0() }
                subject.disappearWindow { _ in }
                
                XCTAssertEqual(output.fixWindowCallCount, 1)
                XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
                XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 1)
                XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 1)
                XCTAssertEqual(contentView.showReappearRightButtonCallCount, 0)
                XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 0)
                XCTAssertEqual(output.setWindowAlphaCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.4)
            }
            XCTContext.runActivity(named: "bottomRight") { _ in
                setUp()
                userSetting.latestPosition = .bottomRight
                slideOverService.hideWindowHandler = { _, _ in true }
                output.isMiniaturized = false

                contentView.showReappearLeftButtonHandler = { $0() }
                subject.disappearWindow { _ in }
                
                XCTAssertEqual(output.fixWindowCallCount, 1)
                XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
                XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 1)
                XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 1)
                XCTAssertEqual(contentView.showReappearRightButtonCallCount, 0)
                XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 0)
                XCTAssertEqual(output.setWindowAlphaCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.4)

            }
        }
        
        XCTContext.runActivity(named: "ポジションがleft側のとき") { _ in
            XCTContext.runActivity(named: "left") { _ in
                setUp()
                userSetting.latestPosition = .left
                slideOverService.hideWindowHandler = { _, _ in true }
                output.isMiniaturized = false
                
                contentView.showReappearRightButtonHandler = { $0() }
                subject.disappearWindow { _ in }

                XCTAssertEqual(output.fixWindowCallCount, 1)
                XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
                XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 0)
                XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 0)
                XCTAssertEqual(contentView.showReappearRightButtonCallCount, 1)
                XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.4)
            }
            XCTContext.runActivity(named: "topLeft") { _ in
                setUp()
                userSetting.latestPosition = .topLeft
                slideOverService.hideWindowHandler = { _, _ in true }
                output.isMiniaturized = false

                contentView.showReappearRightButtonHandler = { $0() }
                subject.disappearWindow { _ in }

                XCTAssertEqual(output.fixWindowCallCount, 1)
                XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
                XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 0)
                XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 0)
                XCTAssertEqual(contentView.showReappearRightButtonCallCount, 1)
                XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.4)
            }
            XCTContext.runActivity(named: "bottomLeft") { _ in
                setUp()
                userSetting.latestPosition = .bottomLeft
                slideOverService.hideWindowHandler = { _, _ in true }
                output.isMiniaturized = false

                contentView.showReappearRightButtonHandler = { $0() }
                subject.disappearWindow { _ in }

                XCTAssertEqual(output.fixWindowCallCount, 1)
                XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
                XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 0)
                XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 0)
                XCTAssertEqual(contentView.showReappearRightButtonCallCount, 1)
                XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaCallCount, 1)
                XCTAssertEqual(output.setWindowAlphaArgValues.first, 0.4)
            }
        }
        
        XCTContext.runActivity(named: "hideWindowに失敗したら何もしないこと") { _ in
            setUp()
            userSetting.latestPosition = .bottomLeft
            slideOverService.hideWindowHandler = { _, _ in false }
            output.isMiniaturized = false
            
            var isSuccess: Bool?
            subject.disappearWindow { isSuccess = $0 }
            
            XCTAssertEqual(output.fixWindowCallCount, 1)
            XCTAssertEqual(slideOverService.hideWindowCallCount, 1)
            XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 0)
            XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 0)
            XCTAssertEqual(contentView.showReappearRightButtonCallCount, 0)
            XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 0)
            XCTAssertEqual(isSuccess, false)
        }
        
        XCTContext.runActivity(named: "ウィンドウが最小されているとき") { _ in
            setUp()
            userSetting.latestPosition = .bottomLeft
            slideOverService.hideWindowHandler = { _, _ in true }
            output.isMiniaturized = true
            
            var isSuccess: Bool?
            subject.disappearWindow { isSuccess = $0 }
            
            XCTAssertEqual(output.fixWindowCallCount, 0)
            XCTAssertEqual(slideOverService.hideWindowCallCount, 0)
            XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 0)
            XCTAssertEqual(contentView.showReappearLeftButtonCallCount, 0)
            XCTAssertEqual(contentView.showReappearRightButtonCallCount, 0)
            XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 0)
            XCTAssertEqual(isSuccess, false)
        }
    }
    
    func test_appearWindow() {
        XCTContext.runActivity(named: "ウィンドウが最小されていないとき") { _ in
            setUp()
            userSetting.latestPosition = .bottomLeft
            output.isMiniaturized = false
            
            var isSuccess: Bool?
            subject.appearWindow { isSuccess = $0 }
            
            XCTAssertEqual(output.setWindowAlphaCallCount, 1)
            XCTAssertEqual(output.setWindowAlphaArgValues.first, 1.0)
            XCTAssertEqual(output.fixWindowCallCount, 1)
            XCTAssertEqual(slideOverService.fixWindowCallCount, 1)
            XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 1)
            XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 1)
            XCTAssertEqual(isSuccess, true)
        }

        XCTContext.runActivity(named: "ウィンドウが最小されているとき") { _ in
            setUp()
            userSetting.latestPosition = .bottomLeft
            output.isMiniaturized = true
            
            var isSuccess: Bool?
            subject.appearWindow { isSuccess = $0 }
            
            XCTAssertEqual(output.setWindowAlphaCallCount, 0)
            XCTAssertEqual(output.fixWindowCallCount, 0)
            XCTAssertEqual(slideOverService.fixWindowCallCount, 0)
            XCTAssertEqual(contentView.hideReappearLeftButtonCallCount, 0)
            XCTAssertEqual(contentView.hideReappearRightButtonCallCount, 0)
            XCTAssertEqual(isSuccess, false)
        }

    }
}
