import Foundation
import Swinject
import Injectable

class AppContainer {
    
    static func build() -> Container {
        let container = Container()
        
        container.register(ScreenManager.self) { _ in ScreenManagerImpl() }
        container.register(ApplicationService.self) { _ in ApplicationServiceImpl() }
        container.register(WindowManager.self) { _ in WindowManagerImpl() }
        container.register(UIQueue.self) { _ in DispatchQueue.main }
        container.register(GlobalShortcutService.self) { _ in GlobalShortcutServiceImpl() }
        container.register(NotificationManager.self) { _ in NotificationManagerImpl() }
        container.register(AlertService.self) { _ in AlertServiceImpl() }
        container.register(URLValidationService.self) { _ in URLValidationServiceImpl() }
        container.register(URLEncodeService.self) { _ in URLEncodeServiceImpl() }
        container.register(WebViewService.self) { _ in WebViewServiceImpl() }
        container.register(UserSettingService.self) { _ in UserSettingServiceImpl(userDefaults: UserDefaults.standard) }.inObjectScope(.container)
        container.register(SlideOverComputation.self) { injector in SlideOverComputationImpl(injector: injector) }
        container.register(SlideOverService.self) { injector in
            SlideOverServiceImpl(injector: injector)
        }
        
        return container
    }
}

extension Injector {
    static let shared = Injector(container: AppContainer.build())
}
