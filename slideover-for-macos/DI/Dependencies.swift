import Foundation
import Swinject

/// @mockable
protocol Dependencies {
    func register<T>(_ Type: T.Type, factory: @escaping (Resolver) -> T)
    func registerAsSingleton<T>(_ Type: T.Type, factory: @escaping (Resolver) -> T)
}
