import AppKit
import Combine

protocol MainWindowControllable {
    func setBrowserBack(enable: Bool)
    func setBrowserForward(enable: Bool)
}

class MainWindowController: NSWindowController {
    
    private let slideOverService: SlideOverServiceImpl = .init()
    private var didMoveNotificationToken: AnyCancellable?
    private var willMoveNotificationToken: AnyCancellable?
    @IBOutlet weak var browserBackItem: NSToolbarItem!
    @IBOutlet weak var browserForwardItem: NSToolbarItem!
    @IBOutlet weak var searchBar: NSSearchField! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    var contentView: SlideOverViewable? {
        window?.contentViewController as? SlideOverViewable
    }
    
    override func windowDidLoad() {
        if let window = window {
            window.level = .floating
            window.styleMask = [.borderless, .utilityWindow, .titled, .closable]
            window.collectionBehavior = [.canJoinAllSpaces]
            
            DispatchQueue.main.async {
                self.slideOverService.fixWindow(for: window, type: .right)
            }
        }
        
        willMoveNotificationToken = NotificationCenter.default
            .publisher(for: NSWindow.willMoveNotification, object: nil)
            .sink { [weak self] notification in
                self?.setMoveNotification()
            }
    }
    
    private func setMoveNotification() {
        didMoveNotificationToken = NotificationCenter.default.publisher(for: NSWindow.didMoveNotification, object: nil)
            .delay(for: .milliseconds(100), tolerance: nil, scheduler: RunLoop.main, options: nil)
            .filter({ _ in NSEvent.pressedMouseButtons == 0 })
            .prefix(1)
            .sink { notification in
                guard let window = notification.object as? NSWindow else { return }
                DispatchQueue.main.async {
                    self.slideOverService.fixMovedWindow(for: window)
                }
            }
    }
    
    @objc func didTapBrowserBackItem(_ sender: Any) {
        contentView?.browserBack()
    }
    
    @objc func didTapBrowserForwardItem(_ sender: Any) {
        contentView?.browserForward()
    }
}

extension MainWindowController: NSSearchFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        let urlString = searchBar.stringValue
        guard isValidUrl(url: urlString) else { return }
        contentView?.loadWebView(url: URL(string: urlString))
    }
}

extension MainWindowController: MainWindowControllable {
    func setBrowserBack(enable: Bool) {
        if enable {
            browserBackItem.action = #selector(didTapBrowserBackItem(_:))
        } else {
            browserBackItem.action = nil
        }
        browserBackItem.isEnabled = true
    }
    
    func setBrowserForward(enable: Bool) {
        if enable {
            browserForwardItem.action = #selector(didTapBrowserForwardItem(_:))
        } else {
            browserForwardItem.action = nil
        }
        browserForwardItem.isEnabled = true
    }
}


func isValidUrl(url: String) -> Bool {
    let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
    let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
    let result = urlTest.evaluate(with: url)
    return result
}
