import AppKit
import Swinject
import Injectable

class SettingContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        return container
    }
}

class SettingCoordinator: Coordinator {
    private var windowController: SettingWindowController?
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSWindowController {
        if let windowController = windowController {
            return windowController
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            windowController = storyboard.instantiateController(identifier: "settingWindowController") { coder in
                SettingWindowController(coder: coder)
            }
            return windowController!
        }
    }
}

