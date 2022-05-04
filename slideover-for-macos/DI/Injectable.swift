import Foundation

/// @mockable
public protocol Injectable {
    func build<T>(_ Type: T.Type) -> T
    func buildSafe<T>(_ Type: T.Type) -> T?
}
