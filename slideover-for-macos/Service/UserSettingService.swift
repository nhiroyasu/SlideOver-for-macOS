import Foundation

/// @mockable
protocol UserSettingService {
    var initialPage: URL? { get set }
    var latestPage: URL? { get set }
    var latestPosition: SlideOverKind? { get set }
    var latestWindowSize: NSSize? { get set }
    var latestUserAgent: UserAgent? { get set }
    var isNotAllowedGlobalShortcut: Bool { get set }
    var latestShownFeatureVersion: String? { get set }
}

class UserSettingServiceImpl: UserSettingService {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var initialPage: URL? {
        get {
            userDefaults.url(forKey: "initialPage")
        }
        set {
            userDefaults.set(newValue, forKey: "initialPage")
        }
    }
    
    var latestPage: URL? {
        get {
            userDefaults.url(forKey: "latestPage")
        }
        set {
            userDefaults.set(newValue, forKey: "latestPage")
        }
    }
    
    var latestPosition: SlideOverKind? {
        get {
            let raw = userDefaults.integer(forKey: "latestPosition")
            return SlideOverKind(rawValue: raw)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: "latestPosition")
        }
    }
    
    var latestUserAgent: UserAgent? {
        get {
            let raw = userDefaults.integer(forKey: "latestUserAgent")
            return UserAgent(rawValue: raw)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: "latestUserAgent")
        }
    }
    
    var isNotAllowedGlobalShortcut: Bool {
        get {
            userDefaults.bool(forKey: "isNotAllowedGlobalShortcut")
        }
        set {
            userDefaults.set(newValue, forKey: "isNotAllowedGlobalShortcut")
        }
    }
    
    var latestShownFeatureVersion: String? {
        get {
            userDefaults.string(forKey: "latestShownFeatureVersion")
        }
        set {
            userDefaults.set(newValue, forKey: "latestShownFeatureVersion")
        }
    }
    
    var latestWindowSize: NSSize? {
        get {
            let array = userDefaults.array(forKey: "latestWindowSize") as? [Double]
            if let array = array {
                return NSSize(width: array[0], height: array[1])
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                userDefaults.set([Double(newValue.width), Double(newValue.height)], forKey: "latestWindowSize")
            } else {
                userDefaults.set(nil, forKey: "latestWindowSize")
            }
        }
    }
}
