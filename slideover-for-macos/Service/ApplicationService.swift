import Foundation

func isTesting() -> Bool {
    return NSClassFromString("XCTest") != nil // nil じゃなかったらテスト実行中
}

/// @mockable
protocol ApplicationService {
    var appVersion: String? { get }
    var featurePresentVersion: String { get }
    func open(_ url: URL)
}

class ApplicationServiceImpl: ApplicationService {
    var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var featurePresentVersion: String {
        "1.4.0"
    }
    
    func open(_ url: URL) {
        if isTesting() {
            return
        } else {
            NSWorkspace.shared.open(url)
        }
    }
}
