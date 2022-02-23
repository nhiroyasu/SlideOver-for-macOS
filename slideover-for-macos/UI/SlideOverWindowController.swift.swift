import AppKit
import Combine

protocol SlideOverWindowControllable {
    func setBrowserBack(enable: Bool)
    func setBrowserForward(enable: Bool)
    func fixWindow(handle: @escaping (NSWindow?) -> Void)
    func loadWebPage(url: URL?)
    var action: SlideOverWindowAction { get }
}

class SlideOverWindowController: NSWindowController {

    @IBOutlet weak var browserBackItem: NSToolbarItem!
    @IBOutlet weak var browserForwardItem: NSToolbarItem!
    @IBOutlet weak var browserReloadItem: NSToolbarItem! {
        didSet {
            browserReloadItem.action = #selector(didTapBrowserReloadItem(_:))
        }
    }
    @IBOutlet weak var registerInitialPageItem: NSToolbarItem! {
        didSet {
            registerInitialPageItem.action = #selector(didTapRegisterInitialPageItem(_:))
        }
    }
    @IBOutlet weak var searchBar: NSSearchField! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    let action: SlideOverWindowAction
    
    init?(coder: NSCoder, injector: Injectable) {
        self.action = injector.build(SlideOverWindowAction.self)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var contentView: SlideOverViewable? {
        window?.contentViewController as? SlideOverViewable
    }
    
    override func windowDidLoad() {
        window?.level = .floating
        window?.styleMask = [.borderless, .utilityWindow, .titled, .closable]
        window?.collectionBehavior = [.canJoinAllSpaces]
    }
    
    override func showWindow(_ sender: Any?) {
        action.showWindow()
        super.showWindow(sender)
    }
    
    @objc func didTapBrowserBackItem(_ sender: Any) {
        contentView?.browserBack()
    }
    
    @objc func didTapBrowserForwardItem(_ sender: Any) {
        contentView?.browserForward()
    }
    
    @objc func didTapBrowserReloadItem(_ sender: Any) {
        contentView?.browserReload()
    }
    
    @objc func didTapRegisterInitialPageItem(_ sender: Any) {
        guard let url = contentView?.currentUrl else { return }
        action.didTapInitialPageItem(currentUrl: url)
    }
}

extension SlideOverWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(nil)
    }
}

extension SlideOverWindowController: NSSearchFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        let urlString = searchBar.stringValue
        guard isValidUrl(url: urlString) else { return }
        contentView?.loadWebPage(url: URL(string: urlString))
    }
}

extension SlideOverWindowController: SlideOverWindowControllable {
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
    
    func fixWindow(handle: @escaping (NSWindow?) -> Void) {
        handle(window)
    }
    
    func loadWebPage(url: URL?) {
        contentView?.loadWebPage(url: url)
    }
}


func isValidUrl(url: String) -> Bool {
    let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
    let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
    let result = urlTest.evaluate(with: url)
    return result
}
