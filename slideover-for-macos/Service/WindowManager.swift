import Foundation

enum AppWindow {
    case slideover
    case setting
    case featurePresent
    
    var storyboardId: String {
        switch self {
        case .slideover:
            return "slideOverWindowController"
        case .setting:
            return "settingWindowController"
        case .featurePresent:
            return "featurePresentWindowController"
        }
    }
    
    var WC: NSWindowController.Type {
        switch self {
        case .slideover:
            return SlideOverWindowController.self
        case .setting:
            return SettingWindowController.self
        case .featurePresent:
            return FeaturePresentWindowController.self
        }
    }
}

/// @mockable
protocol WindowManager {
    func lunch(_ window: AppWindow)
}

class WindowManagerImpl: WindowManager {
    // 現状、Main.storyboardにあるWindowしか開けない
    // DIに対応していない
    // 何個も同じウィンドウが生成されてしまう
    func lunch(_ window: AppWindow) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let wc: NSWindowController = storyboard.instantiateController(identifier: window.storyboardId) { coder in
            window.WC.init(coder: coder)
        }
        wc.showWindow(nil)
    }
}
