import Foundation
import WebKit
import Injectable

/// @mockable
protocol SlideOverWebViewMenuDelegate {
    func didTapCopyLink()
    func didTapOpenBrowser()
    func didTapWindowLayout(type: SlideOverKind)
    func didTapUserAgent(_ userAgent: UserAgent)
    func didTapHideWindow()
    func didTapHelp()
    func didTapSetting()
}

class SlideOverWebView: WKWebView {
    var delegate: SlideOverWebViewMenuDelegate?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        configuration.preferences._setFullScreenEnabled(true)
        super.init(frame: frame, configuration: configuration)
        translatesAutoresizingMaskIntoConstraints = false
        allowsBackForwardNavigationGestures = true
        allowsLinkPreview = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var userSettingService: UserSettingService? {
        Injector.shared.buildSafe(UserSettingService.self)
    }
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        let menuTree: [MenuItemType] = [
            .separator,
            .item(data: .init(title: NSLocalizedString("Copy Link This Page", comment: ""), action: #selector(didTapCopyLink), keyEquivalent: "", image: nil, value: nil)),
            .item(data: .init(title: NSLocalizedString("Open Browser", comment: ""), action: #selector(didTapOpenBrowser), keyEquivalent: "", image: nil, value: nil)),
            .separator,
            .subMenu(data: .init(title: NSLocalizedString("Window Layout", comment: ""), image: NSImage(systemSymbolName: "uiwindow.split.2x1", accessibilityDescription: nil), items: [
                .init(title: NSLocalizedString("Left", comment: ""), action: #selector(didTapWindowLayoutForRight), keyEquivalent: "", image: NSImage(named: "window_layout_right"), value: SlideOverKind.right),
                .init(title: NSLocalizedString("Right", comment: ""), action: #selector(didTapWindowLayoutForLeft), keyEquivalent: "", image: NSImage(named: "window_layout_left"), value: SlideOverKind.left),
                .init(title: NSLocalizedString("Top Right", comment: ""), action: #selector(didTapWindowLayoutForRightTop), keyEquivalent: "", image: NSImage(named: "window_layout_right_top"), value: SlideOverKind.topRight),
                .init(title: NSLocalizedString("Bottom Right", comment: ""), action: #selector(didTapWindowLayoutForRightBottom), keyEquivalent: "", image: NSImage(named: "window_layout_right_bottom"), value: SlideOverKind.bottomRight),
                .init(title: NSLocalizedString("Top Left", comment: ""), action: #selector(didTapWindowLayoutForLeftTop), keyEquivalent: "", image: NSImage(named: "window_layout_left_top"), value: SlideOverKind.topLeft),
                .init(title: NSLocalizedString("Bottom Left", comment: ""), action: #selector(didTapWindowLayoutForLeftBottom), keyEquivalent: "", image: NSImage(named: "window_layout_left_bottom"), value: SlideOverKind.bottomLeft),
            ], customHandler: { [weak self] data, menuItem in
                if self?.userSettingService?.latestPosition == data.value as? SlideOverKind {
                    menuItem.state = .on
                }
            })),
            .subMenu(data: .init(title: NSLocalizedString("Switch Display", comment: ""), image: NSImage(systemSymbolName: "display.2", accessibilityDescription: nil), items: [
                .init(title: NSLocalizedString("Mobile", comment: ""), action: #selector(didTapUserAgentForMobile), keyEquivalent: "", image: NSImage(systemSymbolName: "iphone", accessibilityDescription: nil), value: UserAgent.phone),
                .init(title: NSLocalizedString("Desktop", comment: ""), action: #selector(didTapUserAgentForDesktop), keyEquivalent: "", image: NSImage(systemSymbolName: "laptopcomputer", accessibilityDescription: nil), value: UserAgent.desktop),
            ], customHandler: { [weak self] data, menuItem in
                if self?.userSettingService?.latestUserAgent == data.value as? UserAgent {
                    menuItem.state = .on
                }
            })),
            .item(data: .init(title: NSLocalizedString("Hide Window", comment: ""), action: #selector(didTapHideWindow), keyEquivalent: "s", keyEquivalentModify: [.command, .control], image: NSImage(systemSymbolName: "eye.slash", accessibilityDescription: nil))),
            .separator,
            .item(data: .init(title: NSLocalizedString("Help", comment: ""), action: #selector(didTapHelp), keyEquivalent: "", image: NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil))),
            .item(data: .init(title: NSLocalizedString("Setting", comment: ""), action: #selector(didTapSetting), keyEquivalent: ",", image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)))
        ]
        buildMenu(from: menuTree, for: menu)
        super.willOpenMenu(menu, with: event)
    }
    
    @objc func didTapCopyLink() {
        delegate?.didTapCopyLink()
    }
    
    @objc func didTapOpenBrowser() {
        delegate?.didTapOpenBrowser()
    }

    @objc func didTapWindowLayoutForRight() {
        delegate?.didTapWindowLayout(type: .right)
    }
    
    @objc func didTapWindowLayoutForLeft() {
        delegate?.didTapWindowLayout(type: .left)
    }
    
    @objc func didTapWindowLayoutForRightTop() {
        delegate?.didTapWindowLayout(type: .topRight)
    }
    
    @objc func didTapWindowLayoutForRightBottom() {
        delegate?.didTapWindowLayout(type: .bottomRight)
    }
    
    @objc func didTapWindowLayoutForLeftTop() {
        delegate?.didTapWindowLayout(type: .topLeft)
    }
    
    @objc func didTapWindowLayoutForLeftBottom() {
        delegate?.didTapWindowLayout(type: .bottomLeft)
    }
    
    @objc func didTapUserAgentForMobile() {
        delegate?.didTapUserAgent(.phone)
    }
    
    @objc func didTapUserAgentForDesktop() {
        delegate?.didTapUserAgent(.desktop)
    }
    
    @objc func didTapHideWindow() {
        delegate?.didTapHideWindow()
    }

    @objc func didTapHelp() {
        delegate?.didTapHelp()
    }
    
    @objc func didTapSetting() {
        delegate?.didTapSetting()
    }
}
