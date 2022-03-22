import AppKit
import Combine

protocol SlideOverWindowControllable {
    func setBrowserBack(enable: Bool)
    func setBrowserForward(enable: Bool)
    func fixWindow(handle: @escaping (NSWindow?) -> Void)
    func loadWebPage(url: URL?)
    var progressBar: NSProgressIndicator? { get }
    var action: SlideOverWindowAction { get }
    var contentView: SlideOverViewable? { get }
    var webDisplayTypeItem: NSToolbarItem! { get }
    var windowWillResizeHandler: ((NSWindow, NSSize) -> NSSize)? { get set }
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
    @IBOutlet weak var webDisplayTypeItem: NSToolbarItem! {
        didSet {
            webDisplayTypeItem.action = #selector(didTapWebDisplayTypeItem(_:))
        }
    }
    @IBOutlet weak var bookmarkItem: NSToolbarItem!
    
    let action: SlideOverWindowAction
    private let urlValidationService: URLValidationService
    
    init?(coder: NSCoder, injector: Injectable) {
        self.action = injector.build(SlideOverWindowAction.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var contentView: SlideOverViewable? {
        window?.contentViewController as? SlideOverViewable
    }
    
    var windowWillResizeHandler: ((NSWindow, NSSize) -> NSSize)?
    
    override func windowDidLoad() {
        window?.level = .floating
        window?.styleMask = [.borderless, .utilityWindow, .titled, .closable, .miniaturizable, .resizable]
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
    
    @objc func didTapWebDisplayTypeItem(_ sender: Any) {
        action.didTapDisplayType()
    }
}

extension SlideOverWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(nil)
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        return windowWillResizeHandler?(sender, frameSize) ?? frameSize
    }
}

extension SlideOverWindowController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let urlString = searchBar.stringValue
            action.inputSearchBar(input: urlString)
            return false
        }
        return false
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
    
    var progressBar: NSProgressIndicator? {
        contentView?.progressBar
    }
}

