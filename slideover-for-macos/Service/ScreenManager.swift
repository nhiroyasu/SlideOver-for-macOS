import Foundation

protocol ScreenManager {
    /// メインスクリーンの利用可能な領域
    var mainFrame: ObjectFrame { get }
    /// メインスクリーン全体の領域
    var mainAbsoluteFrame: ObjectFrame { get }
}

class ScreenManagerImpl: ScreenManager {
    
    var mainFrame: ObjectFrame {
        guard let mainScreen = NSScreen.main else { return .init(from: NSRect.zero) }
        return ObjectFrame(from: mainScreen.visibleFrame)
    }
    
    var mainAbsoluteFrame: ObjectFrame {
        guard let mainScreen = NSScreen.main else { return .init(from: NSRect.zero) }
        return ObjectFrame(from: mainScreen.frame)
    }
}
