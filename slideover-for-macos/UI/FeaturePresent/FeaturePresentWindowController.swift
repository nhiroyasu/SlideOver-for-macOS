import Cocoa

class FeaturePresentWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.isMovable = false
        window?.level = .floating
        DispatchQueue.main.mainAsyncAfter(deadline: .now() + 0.5) {
            self.window?.level = .normal
            self.window?.becomeMain()
        }
    }
}
