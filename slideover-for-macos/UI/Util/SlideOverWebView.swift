import Foundation
import WebKit

protocol SlideOverWebViewMenuDelegate {
    func didTapCopyLink()
    func didTapOpenBrowser()
    func didTapRegisterInitialPage()
}

class SlideOverWebView: WKWebView {
    var delegate: SlideOverWebViewMenuDelegate?
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        menu.addItem(.separator())
        menu.addItem(withTitle: "リンクをコピー", action: #selector(didTapCopyLink), keyEquivalent: "")
        menu.addItem(withTitle: "ブラウザで開く", action: #selector(didTapOpenBrowser), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "初期ページに設定", action: #selector(didTapRegisterInitialPage), keyEquivalent: "")
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
    
}
