import Foundation
import XCTest
@testable import Fixture_in_Picture
import Swinject

class SlideOverWindowActionTests: XCTestCase {
    
    var subject: SlideOverWindowActionImpl!
    var useCase: SlideOverWindowUseCaseMock!
    var urlValidationService: URLValidationServiceMock!
    
    override func setUp() {
        super.setUp()
        
        useCase = .init()
        urlValidationService = .init()
        let container = Container()
        container.register(SlideOverWindowUseCase.self, impl: useCase)
        container.register(URLValidationService.self, impl: urlValidationService)
        let injector = TestInjector(container: container)
        subject = .init(injector: injector)
    }
    
    func test_showWindow() {
        subject.showWindow()
        
        XCTAssertEqual(useCase.setUpCallCount, 1)
    }
    
    func test_inputSearchBar() {
        XCTContext.runActivity(named: "URLのとき、そのURLを表示させること") { _ in
            setUp()
            urlValidationService.isUrlHandler = { _ in true }
            
            subject.inputSearchBar(input: "https://yahoo.co.jp")
            
            XCTAssertEqual(urlValidationService.isUrlCallCount, 1)
            XCTAssertEqual(useCase.loadWebPageCallCount, 1)
            XCTAssertEqual(useCase.searchGoogleCallCount, 0)
        }
        
        XCTContext.runActivity(named: "URLではない時、そのワードでGoogole検索すること") { _ in
            setUp()
            urlValidationService.isUrlHandler = { _ in false }
            
            subject.inputSearchBar(input: "お菓子")
            
            XCTAssertEqual(urlValidationService.isUrlCallCount, 1)
            XCTAssertEqual(useCase.loadWebPageCallCount, 0)
            XCTAssertEqual(useCase.searchGoogleCallCount, 1)
        }
    }
    
    func test_didTapInitialPageItem() {
        subject.didTapInitialPageItem(currentUrl: .stubUrl)
        
        XCTAssertEqual(useCase.registerInitialPageCallCount, 1)
        XCTAssertEqual(useCase.registerInitialPageArgValues.first, .stubUrl)
    }
    
    func test_didChangePage() {
        subject.didChangePage(url: .stubUrl)
        
        XCTAssertEqual(useCase.registerLatestPageCallCount, 1)
        XCTAssertEqual(useCase.registerLatestPageArgValues.first, .stubUrl)
    }
    
    func test_didChangePosition() {
        subject.didChangePosition(kind: .left)
        
        XCTAssertEqual(useCase.registerLatestPositionCallCount, 1)
        XCTAssertEqual(useCase.registerLatestPositionArgValues.first, .left)
    }
    
    func test_didUpdateProgress() {
        subject.didUpdateProgress(value: 0.3)
        
        XCTAssertEqual(useCase.updateProgressCallCount, 1)
        XCTAssertEqual(useCase.updateProgressArgValues.first, 0.3)
    }
    
    func test_didTapDisplayType() {
        subject.didTapDisplayType()
        
        XCTAssertEqual(useCase.switchUserAgentCallCount, 1)
    }
    
    func test_didTapChangingPositionButton() {
        subject.didTapChangingPositionButton(type: .right)
        
        XCTAssertEqual(useCase.requestChangingPositionCallCount, 1)
    }
    
    func test_didTapUpdateUserAgent() {
        subject.didTapUpdateUserAgent(.phone)
        
        XCTAssertEqual(useCase.updateUserAgentCallCount, 1)
        XCTAssertEqual(useCase.updateUserAgentArgValues.first, .phone)
    }
    
    func test_didTapHideWindow() {
        subject.didTapHideWindow()
        
        XCTAssertEqual(useCase.requestDisappearWindowCallCount, 1)
    }
    
    func test_didTapHelp() {
        subject.didTapHelp()
        
        XCTAssertEqual(useCase.showHelpPageCallCount, 1)
    }
    
    func test_didTapReappearButton() {
        subject.didTapReappearButton()
        
        XCTAssertEqual(useCase.requestAppearWindowCallCount, 1)
    }
}
