import Magnet

enum GlobalShortcutKey: String {
    case command_control_s
    
    var keyCombo: KeyCombo? {
        switch self {
        case .command_control_s:
            return KeyCombo(key: .s, cocoaModifiers: [.command, .control])
        }
    }
}

protocol GlobalShortcutService {
    func register(keyType: GlobalShortcutKey, action: @escaping () -> Void)
}

class GlobalShortcutServiceImpl: GlobalShortcutService {
    func register(keyType: GlobalShortcutKey, action: @escaping () -> Void) {
        if let keyCombo = keyType.keyCombo {
            let hotKey = HotKey(identifier: keyType.rawValue, keyCombo: keyCombo, actionQueue: .main) { _ in
                action()
            }
            hotKey.register()
        }
    }
}
