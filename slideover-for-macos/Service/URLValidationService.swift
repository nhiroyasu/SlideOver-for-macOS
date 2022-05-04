import Foundation

/// @mockable
protocol URLValidationService {
    func isUrl(text: String) -> Bool
}

class URLValidationServiceImpl: URLValidationService {
    func isUrl(text: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: text)
        return result
    }
}
