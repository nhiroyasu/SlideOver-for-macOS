import Foundation
import WebKit

protocol SlideOverWebViewMenuDelegate {
    func didTapCopyLink()
    func didTapOpenBrowser()
    func didTapRegisterInitialPage()
    func didTapWindowLayout(type: SlideOverKind)
    func didTapUserAgent(_ userAgent: UserAgent)
}

class SlideOverWebView: WKWebView {
    var delegate: SlideOverWebViewMenuDelegate?
    
    private var userSettingService: UserSettingService? {
        Injector.shared.buildSafe(UserSettingService.self)
    }
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        let menuTree: [MenuItemType] = [
            .separator,
            .item(data: .init(title: NSLocalizedString("Copy Link", comment: ""), action: #selector(didTapCopyLink), keyEquivalent: "", image: nil, value: nil)),
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
            }))
        ]
        buildMenu(from: menuTree, for: menu)
    }
    
    @objc func didTapCopyLink() {
        delegate?.didTapCopyLink()
    }
    
    @objc func didTapOpenBrowser() {
        delegate?.didTapOpenBrowser()
    }
    
    @objc func didTapRegisterInitialPage() {
        delegate?.didTapRegisterInitialPage()
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
}
