import Foundation
import Swinject

class Injector: Injectable {
    
    static let shared: Injector = Injector(container: AppContainer.build())
    let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func build<T>(_ Type: T.Type) -> T {
        self.container.resolve(T.self)!
    }
    
    func buildSafe<T>(_ Type: T.Type) -> T? {
        self.container.resolve(T.self)
    }

//    func register<T>(_ Type: T.Type, factory: @escaping (Resolver) -> T) {
//        self.container.register(Type.self, name: nil, factory: factory)
//    }
//
//    func registerAsSingleton<T>(_ Type: T.Type, factory: @escaping (Resolver) -> T) {
//        self.container.register(Type.self, name: nil, factory: factory).inObjectScope(.container)
//    }
}
