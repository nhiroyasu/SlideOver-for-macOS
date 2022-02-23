import Cocoa
import WebKit

protocol SlideOverViewable {
    func loadWebPage(url: URL?)
    func browserBack()
    func browserForward()
}

class ViewController: NSViewController {
    
    @IBOutlet var webView: WKWebView!
    private let slideOverService: SlideOverServiceImpl = .init()
    private var observers = [NSKeyValueObservation]()
    
    private var contentWindow: MainWindowControllable? {
        view.window?.windowController as? MainWindowControllable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        loadWebPage(url: URL(string: "https://yahoo.co.jp/"))
    }

    private func setupWebView() {
        webView.uiDelegate = self
        webView.navigationDelegate = self
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

extension ViewController: SlideOverViewable {
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
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated && navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
    }
}

extension ViewController: WKUIDelegate {
}
