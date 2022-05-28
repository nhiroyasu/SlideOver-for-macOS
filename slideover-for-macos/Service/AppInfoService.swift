import Foundation

/// @mockable
protocol AppInfoService {
    var appVersion: String? { get }
    var featurePresentVersion: String { get }
}

class AppInfoServiceImpl: AppInfoService {
    var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var featurePresentVersion: String {
        "1.4.0"
    }
}
