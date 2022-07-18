import AppKit

public protocol Coordinator {
    func create() -> NSWindowController
}

public protocol NavigationCoordinator: Coordinator {
    func start()
    func dismiss()
}
