import AppKit
import Combine
import Injectable

/// @mockable
protocol SlideOverWindowControllable {
    func setBrowserBack(enable: Bool)
    func setBrowserForward(enable: Bool)
    func fixWindow(handle: @escaping (NSWindow?) -> Void)
    func loadWebPage(url: URL?)
    func focusSearchBar()
    func setWindowAlpha(_ value: CGFloat)
    var isMiniaturized: Bool { get }
    var progressBar: NSProgressIndicator? { get }
    var action: SlideOverAction { get }
    var contentView: SlideOverViewable? { get }
    var webDisplayTypeItem: NSToolbarItem! { get }
}

class SlideOverWindowController: NSWindowController {

    @IBOutlet weak var browserBackItem: NSToolbarItem!
    @IBOutlet weak var browserForwardItem: NSToolbarItem!
    @IBOutlet weak var browserReloadItem: NSToolbarItem! {
        didSet {
            browserReloadItem.action = #selector(didTapBrowserReloadItem(_:))
        }
    }
    @IBOutlet weak var registerInitialPageItem: NSToolbarItem!
    @IBOutlet weak var searchBar: NSSearchField! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var webDisplayTypeItem: NSToolbarItem!
    @IBOutlet weak var bookmarkItem: NSToolbarItem!
    private let state: SlideOverState
    
    let action: SlideOverAction
    private let urlValidationService: URLValidationService
    private let userSettingService: UserSettingService
    
    init?(coder: NSCoder, injector: Injectable, state: SlideOverState) {
        self.action = injector.build(SlideOverAction.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        self.userSettingService = injector.build()
        self.state = state
        super.init(coder: coder)
        observeState()
        actionState()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var contentView: SlideOverViewable? {
        window?.contentViewController as? SlideOverViewable
    }
    
    private var frameObservation: NSKeyValueObservation?
    private var isHiddenOutsideObservation: NSKeyValueObservation?
    private var isHiddenCompletelyObservation: NSKeyValueObservation?
    private var userAgentObservation: NSKeyValueObservation?
    private var urlObservation: NSKeyValueObservation?
    private var zoomObservation: NSKeyValueObservation?
    
    private func observeState() {
        frameObservation = state.observe(\.frame, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            self?.window?.setFrame(value, display: true, animate: true)
        }
        
        isHiddenOutsideObservation = state.observe(\.isHidden, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let self = self, let value = changeValue.newValue else { return }
            if self.userSettingService.isCompletelyHideWindow {
                if value {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        NSApplication.shared.hide(nil)
                    }
                } else {
                    NSApplication.shared.unhide(nil)
                }
            } else {
                if value {
                    // hide
                    self.setWindowAlpha(0.4)
                    self.contentView?.showReappearRightButton(completion: {})
                    self.contentView?.showReappearLeftButton(completion: {})
                } else {
                    // display
                    self.setWindowAlpha(1.0)
                    self.contentView?.hideReappearLeftButton(completion: {})
                    self.contentView?.hideReappearRightButton(completion: {})
                }
            }
        }
        
        isHiddenCompletelyObservation = state.observe(\.isHiddenCompletely, options: [.initial, .new]) { state, changeValue in
            guard let value = changeValue.newValue else { return }
            if value {
                // hide
                NSApplication.shared.hide(nil)
            } else {
                // display
                NSApplication.shared.unhide(nil)
            }
        }
        
        userAgentObservation = state.observe(\.userAgent, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            self?.contentView?.webView.customUserAgent = (UserAgent(rawValue: value) ?? .desktop).context
            self?.contentView?.webView.reloadFromOrigin()
        }
        
        urlObservation = state.observe(\.url, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            self?.contentView?.loadWebPage(url: value)
        }
        
        zoomObservation = state.observe(\.zoom, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            self?.contentView?.webView.setMagnification(value, centeredAt: .zero)
        }
    }
    
    private func actionState() {
        state.reloadAction = { [weak self] in
            self?.contentView?.browserReload()
        }
        
        state.focusAction = { [weak self] in
            self?.focusSearchBar()
        }
    }
    
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
}

extension SlideOverWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        action.windowWillClose(size: window?.frame.size)
        NSApplication.shared.terminate(nil)
    }

    func windowDidEndLiveResize(_ notification: Notification) {
        guard let windowFrame = window?.frame else { return }
        action.windowDidEndLiveResize(windowFrame)
    }
}

extension SlideOverWindowController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let urlString = searchBar.stringValue
            action.didEnterSearchBar(input: urlString)
            return false
        } else if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            window?.makeFirstResponder(nil)
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
    
    func focusSearchBar() {
        window?.makeFirstResponder(searchBar)
    }
    
    func setWindowAlpha(_ value: CGFloat) {
        window?.alphaValue = value
    }
    
    var isMiniaturized: Bool {
        window?.isMiniaturized ?? false
    }
    
    var progressBar: NSProgressIndicator? {
        contentView?.progressBar
    }
}

