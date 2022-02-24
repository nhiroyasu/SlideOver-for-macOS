import Foundation
import Swinject

class AppContainer {
    
    static func build() -> Container {
        let container = Container()
        
        container.register(AlertService.self, impl: AlertServiceImpl())
        container.register(URLValidationService.self, impl: URLValidationServiceImpl())
        container.register(URLEncodeService.self, impl: URLEncodeServiceImpl())
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
