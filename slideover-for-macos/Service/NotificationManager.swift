import Foundation

extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let clearCache = Notification.Name("clearCache")
    static let openUrl = Notification.Name("openUrl")
    static let openUrlForBrowser = Notification.Name("openUrlForBrowser")
    static let openHelp = Notification.Name("openHelp")
    static let searchFocus = Notification.Name("searchFocus")
    static let hideWindow = Notification.Name("hideWindow")
    static let showFeaturePresent = Notification.Name("showFeaturePresent")
}

/// @mockable
protocol NotificationManager {
    func push(name: Notification.Name, param: Any?)
    func observe(name: Notification.Name, handler: @escaping (Any?) -> Void)
}

class NotificationManagerImpl: NotificationManager {
    init() {
        setUpOpenUrlForBrowser()
    }
    
    func push(name: Notification.Name, param: Any?) {
        if let param = param {
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["param": param])
        } else {
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    func observe(name: Notification.Name, handler: @escaping (Any?) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            let param = notification.userInfo?["param"]
            handler(param)
        }
    }
    
    private func setUpOpenUrlForBrowser() {
        observe(name: .openUrlForBrowser) { urlValue in
            guard let urlStr = urlValue as? String,
                  let url = URL(string: urlStr) else { return }
            NSWorkspace.shared.open(url)
        }
    }
}
