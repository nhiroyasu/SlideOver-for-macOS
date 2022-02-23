import Foundation

protocol UserSettingService {
    var initialPage: URL? { get set }
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
}
