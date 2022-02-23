import Foundation
import Swinject

extension Container {
    @discardableResult
    func register<Service>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> {
        self.register(serviceType, name: nil, factory: factory)
    }
    
    @discardableResult
    func register<Service>(_ serviceType: Service.Type, impl: Service) -> ServiceEntry<Service> {
        self.register(serviceType, name: nil) { _ in impl }
    }
}
