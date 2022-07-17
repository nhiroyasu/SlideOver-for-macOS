import Foundation

class SlideOverState: NSObject {
    @objc dynamic var frame: NSRect = NSRect(origin: .zero, size: .init(width: 300, height: 400))
    @objc dynamic var cacheFrame: NSRect = NSRect(origin: .zero, size: .init(width: 300, height: 400))
    @objc dynamic var isHidden: Bool = false
    @objc dynamic var isHiddenCompletely: Bool = false
    @objc dynamic var progress: Double = 0.0
    @objc dynamic var userAgent: Int = UserAgent.desktop.rawValue
    @objc dynamic var url: URL? = nil
    @objc dynamic var zoom: Double = 1.0
    
    var reloadAction: (() -> Void)?
    var focusAction: (() -> Void)?
}
