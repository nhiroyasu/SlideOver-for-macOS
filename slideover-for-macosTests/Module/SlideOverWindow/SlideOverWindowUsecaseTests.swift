import Foundation
import XCTest
@testable import Fixture_in_Picture
import Swinject

class SlideOverWindowUseCaseTests: XCTestCase {
    
    var subject: SlideOverWindowInteractor!
    var userSettingService: UserSettingServiceMock!
    var urlValidationService: URLValidationServiceMock!
    var urlEncodeService: URLEncodeServiceMock!
    var webViewService: WebViewServiceMock!
    var presenter: SlideOverWindowPresenterMock!
    var notificationManager: NotificationManagerMock!
    var globalShortcutService: GlobalShortcutServiceMock!
    
    override func setUp() {
        super.setUp()
        
        userSettingService = .init()
        urlValidationService = .init()
        urlEncodeService = .init()
        webViewService = .init()
        presenter = .init()
        notificationManager = .init()
        globalShortcutService = .init()
        
        let container = Container()

        container.register(UserSettingService.self, impl: userSettingService)
        container.register(URLValidationService.self, impl: urlValidationService)
        container.register(URLEncodeService.self, impl: urlEncodeService)
        container.register(WebViewService.self, impl: webViewService)
        container.register(SlideOverWindowPresenter.self, impl: presenter)
        container.register(NotificationManager.self, impl: notificationManager)
        container.register(GlobalShortcutService.self, impl: globalShortcutService)
        let injector = TestInjector(container: container)
        subject = .init(injector: injector)
    }
    
    func test_setUp() {
        XCTContext.runActivity(named: "notificationManagerが正しく設定されること") { _ in
            setUp()
            subject.setUp()
            
            XCTAssertEqual(notificationManager.observeCallCount, 6)
            XCTAssertEqual(notificationManager.observeArgValues.first, .reload)
            XCTAssertEqual(notificationManager.observeArgValues[1], .clearCache)
            XCTAssertEqual(notificationManager.observeArgValues[2], .openUrl)
            XCTAssertEqual(notificationManager.observeArgValues[3], .openHelp)
            XCTAssertEqual(notificationManager.observeArgValues[4], .searchFocus)
            XCTAssertEqual(notificationManager.observeArgValues[5], .hideWindow)
        }
        
        XCTContext.runActivity(named: "publisherが正しく設定されること") { _ in
            setUp()
            subject.setUp()
            
            XCTAssertNotNil(subject.willMoveNotificationToken)
            XCTAssertNotNil(subject.didDoubleRightClickNotificationToken)
        }
        
        XCTContext.runActivity(named: "resizeHandlerの設定") { _ in
            setUp()
            subject.setUp()
            
            XCTAssertEqual(presenter.setResizeHandlerCallCount, 1)
        }
        
        XCTContext.runActivity(named: "グローバルショートカットの設定") { _ in
            setUp()
            subject.setUp()
            
            XCTAssertEqual(globalShortcutService.registerCallCount, 1)
            XCTAssertEqual(globalShortcutService.registerArgValues.first, .command_control_s)
        }
        
        XCTContext.runActivity(named: "latestPostionの反映") { _ in
            XCTContext.runActivity(named: "保存された値があるとき") { _ in
                setUp()
                userSettingService.latestPosition = .bottomLeft
                
                subject.setUp()
                
                XCTAssertEqual(presenter.fixWindowCallCount, 1)
                XCTAssertEqual(presenter.fixWindowArgValues.first, .bottomLeft)
            }
            
            XCTContext.runActivity(named: "保存された値がないとき") { _ in
                setUp()
                userSettingService.latestPosition = nil
                
                subject.setUp()
                
                XCTAssertEqual(presenter.fixWindowCallCount, 1)
                XCTAssertEqual(presenter.fixWindowArgValues.first, .right)
                XCTAssertEqual(userSettingService.latestPosition, .right)
            }
        }
        
        XCTContext.runActivity(named: "latestPageの反映") { _ in
            XCTContext.runActivity(named: "保存された値があるとき") { _ in
                setUp()
                userSettingService.latestPage = .stubUrl
                
                subject.setUp()
                
                XCTAssertEqual(presenter.setInitialPageCallCount, 1)
                XCTAssertEqual(presenter.setInitialPageArgValues.first, .stubUrl)
            }
            
            XCTContext.runActivity(named: "保存された値がないとき") { _ in
                setUp()
                userSettingService.latestPage = nil
                
                subject.setUp()
                
                XCTAssertEqual(presenter.setInitialPageCallCount, 1)
                XCTAssertEqual(presenter.setInitialPageArgValues.first, URL(string: "https://google.com")!)
            }
        }
        
        XCTContext.runActivity(named: "latestUserAgentの反映") { _ in
            XCTContext.runActivity(named: "保存された値があるとき") { _ in
                setUp()
                userSettingService.latestUserAgent = .phone
                
                subject.setUp()
                
                XCTAssertEqual(presenter.setUserAgentCallCount, 1)
                XCTAssertEqual(presenter.setUserAgentArgValues.first, .phone)
            }
            
            XCTContext.runActivity(named: "保存された値がないとき") { _ in
                setUp()
                userSettingService.latestUserAgent = nil
                
                subject.setUp()
                
                XCTAssertEqual(presenter.setUserAgentCallCount, 1)
                XCTAssertEqual(presenter.setUserAgentArgValues.first, .desktop)
                XCTAssertEqual(userSettingService.latestUserAgent, .desktop)
            }
        }
    }
    
    func test_loadWebPage() {
        subject.loadWebPage(url: .stubUrl)
        
        XCTAssertEqual(presenter.loadWebPageCallCount, 1)
        XCTAssertEqual(presenter.loadWebPageArgValues.first, .stubUrl)
    }
    
    func test_searchGoogle() {
        urlEncodeService.encodeHandler = { _ in "mac+book" }
        subject.searchGoogle(keyword: "mac book")
        
        XCTAssertEqual(presenter.loadWebPageCallCount, 1)
        XCTAssertEqual(presenter.loadWebPageArgValues.first, URL(string: "https://www.google.co.jp/search?q=mac+book")!)
    }
    
    func test_registerInitialPage() {
        subject.registerInitialPage(url: .stubUrl)
        
        XCTAssertEqual(userSettingService.initialPage, .stubUrl)
    }
    
    func test_registerLatestPage() {
        subject.registerLatestPage(url: .stubUrl)
        
        XCTAssertEqual(userSettingService.latestPage, .stubUrl)
    }
    
    func test_registerLatestPosition() {
        subject.registerLatestPosition(kind: .bottomLeft)
        
        XCTAssertEqual(userSettingService.latestPosition, .bottomLeft)
    }
    
    func test_updateProgress() {
        subject.updateProgress(value: 0.5)
        
        XCTAssertEqual(presenter.setProgressCallCount, 1)
        XCTAssertEqual(presenter.setProgressArgValues.first, 50.0)
    }
    
    func test_switchUserAgent() {
        XCTContext.runActivity(named: "phoneのとき") { _ in
            setUp()
            userSettingService.latestUserAgent = .phone
            
            subject.switchUserAgent()
            
            XCTAssertEqual(userSettingService.latestUserAgent, .desktop)
            XCTAssertEqual(presenter.setUserAgentCallCount, 1)
            XCTAssertEqual(presenter.setUserAgentArgValues.first, .desktop)
        }
        
        XCTContext.runActivity(named: "desktopのとき ") { _ in
            setUp()
            userSettingService.latestUserAgent = .desktop
            
            subject.switchUserAgent()
            
            XCTAssertEqual(userSettingService.latestUserAgent, .phone)
            XCTAssertEqual(presenter.setUserAgentCallCount, 1)
            XCTAssertEqual(presenter.setUserAgentArgValues.first, .phone)
        }
    }
    
    func test_updateUserAgent() {
        subject.updateUserAgent(.phone)
        
        XCTAssertEqual(userSettingService.latestUserAgent, .phone)
        XCTAssertEqual(presenter.setUserAgentCallCount, 1)
        XCTAssertEqual(presenter.setUserAgentArgValues.first, .phone)
    }
    
    func test_requestChangingPosition() {
        subject.requestChangingPosition(type: .topRight)
        
        XCTAssertEqual(presenter.fixWindowCallCount, 1)
        XCTAssertEqual(presenter.fixWindowArgValues.first, .topRight)
    }
    
    func test_requestDisappearWindow() {
        subject.requestDisappearWindow()
        
        XCTAssertEqual(subject.state.isWindowHidden, true)
        XCTAssertEqual(presenter.disappearWindowCallCount, 1)
    }
    
    func test_requestAppearWindow() {
        subject.requestAppearWindow()
        
        XCTAssertEqual(subject.state.isWindowHidden, false)
        XCTAssertEqual(presenter.appearWindowCallCount, 1)
    }
    
    func test_showHelpPage() {
        subject.showHelpPage()
        
        XCTAssertEqual(presenter.loadWebPageCallCount, 1)
        XCTAssertEqual(presenter.loadWebPageArgValues.first, URL(string: "https://nhiro.notion.site/Fixture-in-Picture-0eef7a658b4b481a84fbc57d6e43a8f2")!)
    }
}