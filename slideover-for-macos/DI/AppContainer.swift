import Foundation
import Swinject

class AppContainer {
    
    static func build() -> Container {
        let container = Container()
        
        container.register(ApplicationService.self, impl: ApplicationServiceImpl())
        container.register(WindowManager.self, impl: WindowManagerImpl())
        container.register(UIQueue.self, impl: DispatchQueue.main)
        container.register(GlobalShortcutService.self, impl: GlobalShortcutServiceImpl())
        container.register(NotificationManager.self, impl: NotificationManagerImpl())
        container.register(AlertService.self, impl: AlertServiceImpl())
        container.register(URLValidationService.self, impl: URLValidationServiceImpl())
        container.register(URLEncodeService.self, impl: URLEncodeServiceImpl())
        container.register(WebViewService.self, impl: WebViewServiceImpl())
        container.register(UserSettingService.self, impl: UserSettingServiceImpl(userDefaults: UserDefaults.standard)).inObjectScope(.container)
        container.register(SlideOverService.self) { injector in
            SlideOverServiceImpl(injector: injector)
        }
        
        container.register(SlideOverWindowAction.self) { injector in
            SlideOverWindowActionImpl(injector: injector)
        }
        container.register(SlideOverWindowUseCase.self) { injector in
            SlideOverWindowInteractor(injector: injector)
        }
        container.register(SlideOverWindowPresenter.self) { injector in
            SlideOverWindowPresenterImpl(injector: injector)
        }
        
        return container
    }
}
