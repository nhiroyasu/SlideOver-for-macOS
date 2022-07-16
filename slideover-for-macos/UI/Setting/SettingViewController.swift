import Cocoa

class SettingViewController: NSViewController {

    @IBOutlet weak var hideWindowShortcutSwitchButton: NSSwitch!
    @IBOutlet weak var showALittleWhenHideWindowSwitch: NSSwitch!
    var userSetting: UserSettingService?
    var globalShortcutService: GlobalShortcutService?
    var alertService: AlertService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userSetting = Injector.shared.buildSafe(UserSettingService.self)
        globalShortcutService = Injector.shared.buildSafe(GlobalShortcutService.self)
        alertService = Injector.shared.buildSafe(AlertService.self)
        
        if let isNotAllow = userSetting?.isNotAllowedGlobalShortcut {
            hideWindowShortcutSwitchButton.state = isNotAllow ? .off : .on
        }
        
        if let isCompletelyHide = userSetting?.isCompletelyHideWindow {
            showALittleWhenHideWindowSwitch.state = isCompletelyHide ? .off : .on
        }
    }
    
    @IBAction func didTapHideWindowShortcutSwitch(_ sender: Any) {
        switch hideWindowShortcutSwitchButton.state {
        case .on:
            userSetting?.isNotAllowedGlobalShortcut = false
            alertService?.alert(msg: NSLocalizedString("Please restart the application", comment: ""), completionHandler: {})
        case .off:
            userSetting?.isNotAllowedGlobalShortcut = true
            alertService?.alert(msg: NSLocalizedString("Please restart the application", comment: ""), completionHandler: {})
        default:
            break
        }
            
    }
    
    @IBAction func didTapShowALittleWhenHideWindowSwitch(_ sender: Any) {
        switch showALittleWhenHideWindowSwitch.state {
        case .on:
            userSetting?.isCompletelyHideWindow = false
        case .off:
            userSetting?.isCompletelyHideWindow = true
        default:
            break
        }
    }
}
