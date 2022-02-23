import Foundation
import Cocoa

protocol AlertService {
    func alert(msg: String, completionHandler: @escaping () -> Void)
}

class AlertServiceImpl: AlertService {
    
    private func buildAlert(msg: String, type: NSAlert.Style) -> NSAlert {
        let nsAlert = NSAlert()
        nsAlert.alertStyle = type
        nsAlert.messageText = msg
        return nsAlert
    }
    
    func alert(msg: String, completionHandler: @escaping () -> Void) {
        let alert = buildAlert(msg: msg, type: .informational)
        let response = alert.runModal()
        switch response {
        case .cancel:
            completionHandler()
        default:
            break
        }
    }
    
}
