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
}

class SlideOverWindowController: NSWindowController {

    @IBOutlet weak var browserBackItem: NSToolbarItem!
    @IBOutlet weak var browserForwardItem: NSToolbarItem!
    @IBOutlet weak var browserReloadItem: NSToolbarItem! {
        didSet {
            browserReloadItem.action = #selector(didTapBrowserReloadItem(_:))
        }
    }
    @IBOutlet weak var searchBar: NSSearchField! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var actionItem: NSToolbarItem! {
        didSet {
            actionItem.action = #selector(didTapActionItem(_:))
        }
    }
    @IBOutlet weak var actionPopupButton: NSPopUpButton! {
        didSet {
            NotificationCenter.default.addObserver(forName: NSPopUpButton.willPopUpNotification, object: actionPopupButton, queue: .main) { [weak self] notification in
                self?.setUpPopUpButton()
            }
        }
    }
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
    
    // state observation
    private var frameObservation: NSKeyValueObservation?
    private var isHiddenOutsideObservation: NSKeyValueObservation?
    private var isHiddenCompletelyObservation: NSKeyValueObservation?
    private var userAgentObservation: NSKeyValueObservation?
    private var urlObservation: NSKeyValueObservation?
    private var zoomObservation: NSKeyValueObservation?
    // window observation
    private var isMiniaturizedObservation: NSKeyValueObservation?
    
    private func observeState() {
        frameObservation = state.observe(\.frame, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            self?.window?.setFrame(value, display: true, animate: true)
        }
        
        isHiddenOutsideObservation = state.observe(\.isHidden, options: [.initial, .new]) { [weak self] state, changeValue in
            guard let self = self, let value = changeValue.newValue else { return }
            if self.userSettingService.hiddenActionIsMiniaturized {
                if value {
                    self.window?.miniaturize(nil)
                } else {
                    self.window?.deminiaturize(nil)
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
        if userSettingService.hiddenActionIsMiniaturized {
            window?.styleMask = [.borderless, .utilityWindow, .titled, .closable, .miniaturizable, .resizable]
        } else {
            window?.styleMask = [.borderless, .utilityWindow, .titled, .closable, .resizable]
        }
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
    
    @objc func didTapActionItem(_ sender: Any) {
        setUpPopUpButton()
    }
    
    @objc func didTapWindowLayoutForRight() {
        action.didTapWindowLayoutForRightMenuItem()
    }
    
    @objc func didTapWindowLayoutForLeft() {
        action.didTapWindowLayoutForLeftMenuItem()
    }
    
    @objc func didTapWindowLayoutForRightTop() {
        action.didTapWindowLayoutForRightTopMenuItem()
    }
    
    @objc func didTapWindowLayoutForRightBottom() {
        action.didTapWindowLayoutForRightBottomMenuItem()
    }
    
    @objc func didTapWindowLayoutForLeftTop() {
        action.didTapWindowLayoutForLeftTopMenuItem()
    }
    
    @objc func didTapWindowLayoutForLeftBottom() {
        action.didTapWindowLayoutForLeftBottomMenuItem()
    }
    
    @objc func didTapUserAgentForMobile() {
        action.didTapUserAgentForMobileMenuItem()
    }
    
    @objc func didTapUserAgentForDesktop() {
        action.didTapUserAgentForDesktopMenuItem()
    }
    
    @objc func didTapHideWindow() {
        action.didTapHideWindowMenuItem()
    }
    
    @objc func didTapHelp() {
        action.didTapHelpMenuItem()
    }
    
    @objc func didTapSetting() {
        action.didTapSettingMenuItem()
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
    
    func windowDidMiniaturize(_ notification: Notification) {
        state.isHidden = true
    }
    
    func windowDidDeminiaturize(_ notification: Notification) {
        state.isHidden = false
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

extension SlideOverWindowController {
    private func setUpPopUpButton() {
        let menu = actionPopupButton.menu!
        menu.removeAllItems()
        buildMenu(from: menuTree, for: menu)
        actionPopupButton.menu = menu
    }
    
    private var menuTree: [MenuItemType] {
        [
            .item(data: .init(title: "Action", action: nil, keyEquivalent: "", image: NSImage(systemSymbolName: "ellipsis.circle", accessibilityDescription: nil))),
            .separator,
            .subMenu(data: .init(title: NSLocalizedString("Window Layout", comment: ""), image: NSImage(systemSymbolName: "uiwindow.split.2x1", accessibilityDescription: nil), items: [
                .init(title: NSLocalizedString("Left", comment: ""), action: #selector(didTapWindowLayoutForRight), keyEquivalent: "", image: NSImage(named: "window_layout_right"), value: SlideOverKind.right),
                .init(title: NSLocalizedString("Right", comment: ""), action: #selector(didTapWindowLayoutForLeft), keyEquivalent: "", image: NSImage(named: "window_layout_left"), value: SlideOverKind.left),
                .init(title: NSLocalizedString("Top Right", comment: ""), action: #selector(didTapWindowLayoutForRightTop), keyEquivalent: "", image: NSImage(named: "window_layout_right_top"), value: SlideOverKind.topRight),
                .init(title: NSLocalizedString("Bottom Right", comment: ""), action: #selector(didTapWindowLayoutForRightBottom), keyEquivalent: "", image: NSImage(named: "window_layout_right_bottom"), value: SlideOverKind.bottomRight),
                .init(title: NSLocalizedString("Top Left", comment: ""), action: #selector(didTapWindowLayoutForLeftTop), keyEquivalent: "", image: NSImage(named: "window_layout_left_top"), value: SlideOverKind.topLeft),
                .init(title: NSLocalizedString("Bottom Left", comment: ""), action: #selector(didTapWindowLayoutForLeftBottom), keyEquivalent: "", image: NSImage(named: "window_layout_left_bottom"), value: SlideOverKind.bottomLeft),
            ], customHandler: { [weak self] data, menuItem in
                if self?.userSettingService.latestPosition == data.value as? SlideOverKind {
                    menuItem.state = .on
                }
            })),
            .subMenu(data: .init(title: NSLocalizedString("Switch Display", comment: ""), image: NSImage(systemSymbolName: "display.2", accessibilityDescription: nil), items: [
                .init(title: NSLocalizedString("Mobile", comment: ""), action: #selector(didTapUserAgentForMobile), keyEquivalent: "", image: NSImage(systemSymbolName: "iphone", accessibilityDescription: nil), value: UserAgent.phone),
                .init(title: NSLocalizedString("Desktop", comment: ""), action: #selector(didTapUserAgentForDesktop), keyEquivalent: "", image: NSImage(systemSymbolName: "laptopcomputer", accessibilityDescription: nil), value: UserAgent.desktop),
            ], customHandler: { [weak self] data, menuItem in
                if self?.userSettingService.latestUserAgent == data.value as? UserAgent {
                    menuItem.state = .on
                }
            })),
            .item(data: .init(title: NSLocalizedString("Hide Window", comment: ""), action: #selector(didTapHideWindow), keyEquivalent: "s", keyEquivalentModify: [.command, .control], image: NSImage(systemSymbolName: "eye.slash", accessibilityDescription: nil))),
            .separator,
            .item(data: .init(title: NSLocalizedString("Help", comment: ""), action: #selector(didTapHelp), keyEquivalent: "", image: NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil))),
            .item(data: .init(title: NSLocalizedString("Setting", comment: ""), action: #selector(didTapSetting), keyEquivalent: ",", image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)))
        ]
    }
}
