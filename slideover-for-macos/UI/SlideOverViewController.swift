import Cocoa
import WebKit
import Injectable

/// @mockable
protocol SlideOverViewable {
    func loadWebPage(url: URL?)
    func browserBack()
    func browserForward()
    func browserReload()
    var currentUrl: URL? { get }
    var progressBar: NSProgressIndicator! { get }
    var webView: SlideOverWebView! { get }
    func showReappearLeftButton(completion: @escaping () -> Void)
    func showReappearRightButton(completion: @escaping () -> Void)
    func hideReappearLeftButton(completion: @escaping () -> Void)
    func hideReappearRightButton(completion: @escaping () -> Void)
}

class SlideOverViewController: NSViewController {
    @IBOutlet weak var progressBar: NSProgressIndicator! {
        didSet {
            progressBar.doubleValue = 0
        }
    }
    @IBOutlet weak var reappearLeftButton: NSButton! {
        didSet {
            reappearLeftButton.isHidden = true
            reappearLeftButton.alphaValue = 0.0
        }
    }
    @IBOutlet weak var reappearRightButton: NSButton! {
        didSet {
            reappearRightButton.isHidden = true
            reappearRightButton.alphaValue = 0.0
        }
    }
    var webView: SlideOverWebView!
    private var observers = [NSKeyValueObservation]()
    
    private var contentWindow: SlideOverWindowControllable? {
        view.window?.windowController as? SlideOverWindowControllable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        webView = SlideOverWebView(frame: .zero, configuration: configuration)
        setupWebView()
    }

    private func setupWebView() {
        view.subviews.insert(webView, at: 0)
        webView.delegate = self
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.allowsMagnification = true
        
        observers.append(webView.observe(\.title, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.view.window?.title = webView.title ?? ""
        }))
        observers.append(webView.observe(\.canGoBack, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.contentWindow?.setBrowserBack(enable: webView.canGoBack)
        }))
        observers.append(webView.observe(\.canGoForward, options: [.new], changeHandler: { [weak self] webView, _ in
            self?.contentWindow?.setBrowserForward(enable: webView.canGoForward)
        }))
        observers.append(webView.observe(\.estimatedProgress, options: [.new], changeHandler: { [weak self] webView, _ in
            let value = webView.estimatedProgress * 100.0
            self?.progressBar?.layer?.opacity = 1.0
            self?.progressBar?.doubleValue = value
            if value == 100 {
                guard let layer = self?.progressBar?.layer else { return }
                DispatchQueue.main.mainAsyncAfter(deadline: .now() + 0.8) {
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.duration = 0.8
                    animation.fromValue = 1.0
                    animation.toValue = 0.0
                    animation.autoreverses = false
                    animation.isRemovedOnCompletion = false
                    animation.fillMode = .forwards
                    layer.add(animation, forKey: nil)
                }
            }
        }))
    }
    
    @IBAction func didTapReappearLeftButton(_ sender: Any) {
        contentWindow?.action.didTapReappearButton()
    }
    
    @IBAction func didTapReappearRightButton(_ sender: Any) {
        contentWindow?.action.didTapReappearButton()
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
    
    func showReappearLeftButton(completion: @escaping () -> Void) {
        fadeInViewIfNeeded(reappearLeftButton, completion: completion)
    }
    
    func showReappearRightButton(completion: @escaping () -> Void) {
        fadeInViewIfNeeded(reappearRightButton, completion: completion)
    }
    
    func hideReappearLeftButton(completion: @escaping () -> Void) {
        fadeOutViewIfNeeded(reappearLeftButton, completion: completion)
    }
    
    func hideReappearRightButton(completion: @escaping () -> Void) {
        fadeOutViewIfNeeded(reappearRightButton, completion: completion)
    }
    
    private func fadeInViewIfNeeded(_ view: NSView, completion: @escaping () -> Void) {
        guard view.isHidden == true else { return }
        view.isHidden = false
        view.alphaValue = 0.0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            view.animator().alphaValue = 1.0
        } completionHandler: {
            view.alphaValue = 1.0
            completion()
        }
    }
    
    private func fadeOutViewIfNeeded(_ view: NSView, completion: @escaping () -> Void) {
        guard view.isHidden == false else { return }
        view.isHidden = true
        view.alphaValue = 0.0
        completion()
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

extension SlideOverViewController: SlideOverWebViewMenuDelegate {
    func didTapCopyLink() {
        guard let url = webView.url, let nsUrl = NSURL(string: url.absoluteString) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([nsUrl])
    }
    
    func didTapOpenBrowser() {
        guard let url = webView.url else { return }
        NSWorkspace.shared.open(url)
    }

    func didTapWindowLayout(type: SlideOverKind) {
        contentWindow?.action.didTapChangingPositionButton(type: type)
    }
    
    func didTapUserAgent(_ userAgent: UserAgent) {
        contentWindow?.action.didTapUpdateUserAgent(userAgent)
    }
    
    func didTapHideWindow() {
        contentWindow?.action.didTapHideWindow()
    }
    
    func didTapHelp() {
        contentWindow?.action.didTapHelp()
    }
    
    func didTapSetting() {
        contentWindow?.action.didTapSetting()
    }
}
