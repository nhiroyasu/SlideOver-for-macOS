import Cocoa
import WebKit

protocol SlideOverViewable {
    func loadWebPage(url: URL?)
    func browserBack()
    func browserForward()
    func browserReload()
    var currentUrl: URL? { get }
}

class SlideOverViewController: NSViewController {
    
    @IBOutlet var webView: WKWebView! {
        didSet {
            webView.uiDelegate = self
            webView.navigationDelegate = self
        }
    }
    private var observers = [NSKeyValueObservation]()
    
    private var contentWindow: SlideOverWindowControllable? {
        view.window?.windowController as? SlideOverWindowControllable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
    }

    private func setupWebView() {
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        observers.append(webView.observe(\.title, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.view.window?.title = webView.title ?? ""
        }))
        observers.append(webView.observe(\.canGoBack, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.contentWindow?.setBrowserBack(enable: webView.canGoBack)
        }))
        observers.append(webView.observe(\.canGoForward, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.contentWindow?.setBrowserForward(enable: webView.canGoForward)
        }))
    }
}

extension SlideOverViewController: SlideOverViewable {
    public func loadWebPage(url: URL?) {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func browserBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func browserForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    func browserReload() {
        webView.reload()
    }
    
    var currentUrl: URL? {
        webView.url
    }
}

extension SlideOverViewController: WKNavigationDelegate {
}

extension SlideOverViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
