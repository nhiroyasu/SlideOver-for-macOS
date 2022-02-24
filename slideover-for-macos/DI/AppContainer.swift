import Foundation
import Swinject

class AppContainer {
    
    static func build() -> Container {
        let container = Container()
        
        container.register(AlertService.self, impl: AlertServiceImpl())
        container.register(URLValidationService.self, impl: URLValidationServiceImpl())
        container.register(URLEncodeService.self, impl: URLEncodeServiceImpl())
        container.register(UserSettingService.self, impl: UserSettingServiceImpl(userDefaults: UserDefaults.standard)).inObjectScope(.container)
        container.register(SlideOverService.self, impl: SlideOverServiceImpl())
        
        container.register(SlideOverWindowAction.self) { r in
            SlideOverWindowActionImpl(injector: SwinjectInjector(r))
        }
        container.register(SlideOverWindowUseCase.self) { r in
            SlideOverWindowInteractor(injector: SwinjectInjector(r))
        }
        container.register(SlideOverWindowPresenter.self) { r in
            SlideOverWindowPresenterImpl(injector: SwinjectInjector(r))
        }
        
        return container
    }
}
