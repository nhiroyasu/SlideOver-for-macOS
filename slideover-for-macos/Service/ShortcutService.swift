import Foundation
import Magnet

enum Shortcut: String {
    case command_f
    
    var keyCombo: KeyCombo? {
        switch self {
        case .command_f:
            return KeyCombo(key: .f, cocoaModifiers: .command)
        }
    }
}

protocol ShortcutService {
    func setAction(shortcut: Shortcut, action: @escaping () -> Void)
}

class ShortcutServiceImpl: ShortcutService {
    func setAction(shortcut: Shortcut, action: @escaping () -> Void) {
        if let keyCombo = shortcut.keyCombo {
            let hotKey = HotKey(identifier: shortcut.rawValue, keyCombo: keyCombo) { _ in
                action()
            }
            hotKey.register()
        }
    }
}
