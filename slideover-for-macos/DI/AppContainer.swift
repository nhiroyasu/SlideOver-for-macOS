import Foundation
import Swinject

class AppContainer {
    
    static func build() -> Container {
        let container = Container()
        
        container.register(UserSettingService.self, impl: UserSettingServiceImpl(userDefaults: UserDefaults.standard))
        
        return container
    }
}
