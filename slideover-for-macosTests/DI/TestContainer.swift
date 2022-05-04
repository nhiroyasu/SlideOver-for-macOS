//
//  TestContainer.swift
//  Fixture in Picture
//
//  Created by NH on 2022/05/04.
//

import Foundation
import Swinject
@testable import Fixture_in_Picture

class TestContainer {
    
    static func build() -> Container {
        let container = Container()
        
        container.register(GlobalShortcutService.self, impl: GlobalShortcutServiceMock())
        container.register(NotificationManager.self, impl: NotificationManagerMock())
        container.register(AlertService.self, impl: AlertServiceMock())
        container.register(URLValidationService.self, impl: URLValidationServiceMock())
        container.register(URLEncodeService.self, impl: URLEncodeServiceMock())
        container.register(WebViewService.self, impl: WebViewServiceMock())
        container.register(UserSettingService.self, impl: UserSettingServiceImpl(userDefaults: UserDefaults.standard)).inObjectScope(.container)
        container.register(SlideOverService.self) { injector in
            SlideOverServiceImpl(injector: injector)
        }
        
        container.register(SlideOverWindowAction.self) { injector in
            SlideOverWindowActionMock()
        }
        container.register(SlideOverWindowUseCase.self) { injector in
            SlideOverWindowUseCaseMock()
        }
        container.register(SlideOverWindowPresenter.self) { injector in
            SlideOverWindowPresenterMock()
        }
        
        return container
    }
}
