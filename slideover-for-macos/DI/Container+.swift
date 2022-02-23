import Foundation
import Swinject

extension Container {
    @discardableResult
    func register<Service, Arg1>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver, Arg1) -> Service
    ) -> ServiceEntry<Service> {
        self.register(serviceType, name: nil, factory: factory)
    }
    
    @discardableResult
    func register<Service>(_ serviceType: Service.Type, impl: Service) -> ServiceEntry<Service> {
        self.register(serviceType, name: nil) { _ in impl }
    }
}
