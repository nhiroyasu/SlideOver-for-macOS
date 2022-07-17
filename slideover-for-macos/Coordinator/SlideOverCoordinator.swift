import AppKit
import Swinject
import Injectable

class SlideOverContainerBuilder {
    static func build(parent: Container?, state: SlideOverState) -> Container {
        let container = Container(parent: parent)
        
        container.register(SlideOverAction.self) { resolver in
            SlideOverActionImpl(injector: resolver, state: state)
        }.inObjectScope(.container)
        container.register(SlideOverUseCase.self) { resolver in
            SlideOverInteractor(injector: resolver)
        }.inObjectScope(.container)
        container.register(SlideOverPresenter.self) { resolver in
            SlideOverPresenterImpl(injector: resolver, state: state)
        }.inObjectScope(.container)
        container.register(SlideOverNotificationObserver.self) { resolver in
            SlideOverNotificationObserver(injector: resolver)
        }.inObjectScope(.container)
        
        return container
    }
}

class SlideOverCoordinator: Coordinator {
    private var windowController: SlideOverWindowController!
    private let injector: Injectable
    private let state: SlideOverState
    private let notificationObserver: SlideOverNotificationObserver 
    private lazy var action: SlideOverAction = injector.build()
    private lazy var useCase: SlideOverUseCase = injector.build()
    private lazy var presenter: SlideOverPresenter = injector.build()
    
    init(injector: Injectable, state: SlideOverState) {
        self.injector = injector
        self.state = state
        self.notificationObserver = injector.build()
    }
    
    func create() -> NSWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        windowController = storyboard.instantiateController(identifier: "slideOverWindowController") { coder in
            SlideOverWindowController(coder: coder, injector: self.injector, state: self.state)
        }
        return windowController
    }
}
