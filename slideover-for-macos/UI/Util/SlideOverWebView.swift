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
            .item(data: .init(title: "リンクをコピー", action: #selector(didTapCopyLink), keyEquivalent: "", image: nil, value: nil)),
            .item(data: .init(title: "ブラウザで開く", action: #selector(didTapOpenBrowser), keyEquivalent: "", image: nil, value: nil)),
            .separator,
            .subMenu(data: .init(title: "画面配置", image: NSImage(systemSymbolName: "uiwindow.split.2x1", accessibilityDescription: nil), items: [
                .init(title: "右端", action: #selector(didTapWindowLayoutForRight), keyEquivalent: "", image: NSImage(named: "window_layout_right"), value: SlideOverKind.right),
                .init(title: "左端", action: #selector(didTapWindowLayoutForLeft), keyEquivalent: "", image: NSImage(named: "window_layout_left"), value: SlideOverKind.left),
                .init(title: "右上", action: #selector(didTapWindowLayoutForRightTop), keyEquivalent: "", image: NSImage(named: "window_layout_right_top"), value: SlideOverKind.topRight),
                .init(title: "右下", action: #selector(didTapWindowLayoutForRightBottom), keyEquivalent: "", image: NSImage(named: "window_layout_right_bottom"), value: SlideOverKind.bottomRight),
                .init(title: "左上", action: #selector(didTapWindowLayoutForLeftTop), keyEquivalent: "", image: NSImage(named: "window_layout_left_top"), value: SlideOverKind.topLeft),
                .init(title: "左下", action: #selector(didTapWindowLayoutForLeftBottom), keyEquivalent: "", image: NSImage(named: "window_layout_left_bottom"), value: SlideOverKind.bottomLeft),
            ], customHandler: { [weak self] data, menuItem in
                if self?.userSettingService?.latestPosition == data.value as? SlideOverKind {
                    menuItem.state = .on
                }
            })),
            .subMenu(data: .init(title: "表示切り替え", image: NSImage(systemSymbolName: "display.2", accessibilityDescription: nil), items: [
                .init(title: "モバイル", action: #selector(didTapUserAgentForMobile), keyEquivalent: "", image: NSImage(systemSymbolName: "iphone", accessibilityDescription: nil), value: UserAgent.phone),
                .init(title: "デスクトップ", action: #selector(didTapUserAgentForDesktop), keyEquivalent: "", image: NSImage(systemSymbolName: "laptopcomputer", accessibilityDescription: nil), value: UserAgent.desktop),
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
