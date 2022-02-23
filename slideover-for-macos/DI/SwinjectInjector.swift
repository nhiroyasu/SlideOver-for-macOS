import Foundation
import Swinject

class SwinjectInjector: Injectable {
    
    private let resolver: Resolver
    
    init(_ resolver: Resolver) {
        self.resolver = resolver
    }
    
    func build<T>(_ Type: T.Type) -> T {
        resolver.resolve(T.self)!
    }
    
    func buildSafe<T>(_ Type: T.Type) -> T? {
        resolver.resolve(T.self)
    }
}
