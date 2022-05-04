import Foundation

/// @mockable
protocol WebViewService {
    func clearCache()
}

class WebViewServiceImpl: WebViewService {
    func clearCache() {
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {})
    }
}
