import Cocoa
import WebKit

protocol SlideOverViewable {
    func loadWebView(url: URL?)
    func browserBack()
    func browserForward()
}

class ViewController: NSViewController {
    
    @IBOutlet weak var webView: WKWebView!
    private let slideOverService: SlideOverServiceImpl = .init()
    private var observers = [NSKeyValueObservation]()
    
    private var contentWindow: MainWindowControllable? {
        view.window?.windowController as? MainWindowControllable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        loadWebView(url: URL(string: "https://qiita.com/"))
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func setupWebView() {
        observers.append(webView.observe(\.title, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.view.window?.title = webView.title ?? ""
        }))
        observers.append(webView.observe(\.canGoBack, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.contentWindow?.setBrowserBack(enable: webView.canGoBack)
            print("change")
        }))
        observers.append(webView.observe(\.canGoForward, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.contentWindow?.setBrowserForward(enable: webView.canGoForward)
        }))
    }
}

extension ViewController: SlideOverViewable {
    public func loadWebView(url: URL?) {
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
