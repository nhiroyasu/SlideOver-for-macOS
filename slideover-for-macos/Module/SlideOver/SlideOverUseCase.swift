import Foundation
import Injectable

protocol SlideOverUseCase {
    /// このモジュールの初期設定
    func setUp()
    /// 指定したURLを読み込む
    func load(url: URL?)
    /// ページを再読み込み
    func reload()
    /// ヘルプを表示する
    func showHelp()
    /// 設定を表示する
    func showSetting()
    /// 指定したキーワードをgoogleで検索する
    func searchGoogle(keyword: String)
    /// SlideOverを非表示にする
    func disappear(for windowFrame: ObjectFrame)
    /// SlideOverを表示する
    func appear(for windowFrame: ObjectFrame)
    /// SlideOverを再配置する
    func replace()
    /// SlideoVerを反対方向に移動する
    func reversePosition()
    /// 指定したサイズでリサイズする。サイズが大きすぎる場合、自動で修正される。
    func requestResize(nextFrame: ObjectFrame)
    /// 最後に読んだページとしてurlを保存する
    func memorizeLatestPage(url: URL?)
    /// 最後に移動させたポジションを保存する
    func memorizeLatestPosition(kind: SlideOverKind)
    /// ウィンドウサイズを保存する
    func memorizeLatestWindowSize(_ size: NSSize?)
    /// 指定したユーザエージェントに切り替える
    func updateUserAgent(_ userAgent: UserAgent)
    /// 指定したポジションに移動させる
    func requestChangingPosition(type: SlideOverKind)
    /// キャッシュを削除
    func clearCache()
    /// サーチバーにフォーカスする
    func focusSearchBar()
    /// ズームイン
    func zoomIn()
    /// ズームアウト
    func zoomOut()
    /// ズームリセット
    func zoomReset()
}

class SlideOverInteractor: SlideOverUseCase {
    private let presenter: SlideOverPresenter
    private var userSettingService: UserSettingService
    private var urlValidationService: URLValidationService
    private var urlEncodeService: URLEncodeService
    private let webViewService: WebViewService
    private let notificationManager: NotificationManager
    private let globalShortcutService: GlobalShortcutService
    private let windowManager: WindowManager
    private let appInfoService: ApplicationService
    private let slideOverComputation: SlideOverComputation
    private let screenManager: ScreenManager

    private let defaultInitialPage: URL? = URL(string: "https://google.com")
    private let helpUrl: URL? = URL(string: "https://nhiro.notion.site/Fixture-in-Picture-0eef7a658b4b481a84fbc57d6e43a8f2")
    private let defaultUserAgent: UserAgent = .desktop
    private let defaultSlideOverPosition: SlideOverKind = .right
    
    internal init(injector: Injectable = Injector.shared) {
        self.presenter = injector.build(SlideOverPresenter.self)
        self.userSettingService = injector.build(UserSettingService.self)
        self.slideOverComputation = injector.build(SlideOverComputation.self)
        self.urlValidationService = injector.build(URLValidationService.self)
        self.urlEncodeService = injector.build(URLEncodeService.self)
        self.webViewService = injector.build(WebViewService.self)
        self.notificationManager = injector.build(NotificationManager.self)
        self.globalShortcutService = injector.build(GlobalShortcutService.self)
        self.windowManager = injector.build(WindowManager.self)
        self.appInfoService = injector.build(ApplicationService.self)
        self.screenManager = injector.build(ScreenManager.self)
    }
    
    /// このモジュールの初期設定
    func setUp() {
        // TODO: 初期SlideOverの表示（サイズ、ポジション、URL、UserAgent）
        let windowFrame: NSRect
        if let latestWindowSize = userSettingService.latestWindowSize {
            windowFrame = slideOverComputation.arrangeWindow(for: ObjectFrame(from: latestWindowSize), at: screenManager.mainFrame, type: userSettingService.latestPosition ?? defaultSlideOverPosition)
        } else {
            windowFrame = slideOverComputation.fixWindow(at: screenManager.mainFrame, type: userSettingService.latestPosition ?? defaultSlideOverPosition)
        }
        presenter.fix(at: windowFrame)
        presenter.loadWebPage(url: userSettingService.latestPage)
        presenter.set(userAgent: userSettingService.latestUserAgent ?? defaultUserAgent)
        // TODO: 新機能の表示
    }
    
    /// 指定したURLを読み込む
    func load(url: URL?) {
        presenter.loadWebPage(url: url)
    }
    
    /// ページを再読み込み
    func reload() {
        presenter.reloadWebPage()
    }
    
    /// ヘルプを表示する
    func showHelp() {
        presenter.loadWebPage(url: helpUrl)
    }
    
    func showSetting() {
        presenter.openSettingWindow()
    }
    
    /// 指定したキーワードをgoogleで検索する
    func searchGoogle(keyword: String) {
        let encodedKeyword = urlEncodeService.encode(text: keyword)
        let urlString = "https://www.google.co.jp/search?q=\(encodedKeyword)"
        presenter.loadWebPage(url: URL(string: urlString))
    }
    
    /// SlideOverを非表示にする
    func disappear(for windowFrame: ObjectFrame) {
        let newFrame: NSRect
        if userSettingService.isCompletelyHideWindow {
            newFrame = slideOverComputation.disappearCompletely(for: windowFrame, type: userSettingService.latestPosition ?? defaultSlideOverPosition)
        } else {
            newFrame = slideOverComputation.disappearOutside(for: windowFrame, type: userSettingService.latestPosition ?? defaultSlideOverPosition)
        }
        presenter.fixWithDisappear(at: newFrame)
    }
    
    /// SlideOverを表示する
    func appear(for windowFrame: ObjectFrame) {
        let newFrame = slideOverComputation.arrangeWindow(for: windowFrame, at: screenManager.mainFrame, type: userSettingService.latestPosition ?? defaultSlideOverPosition)
        presenter.fix(at: newFrame)
    }
    
    /// SlideOverを再配置する
    func replace() {
        let windowFrame = slideOverComputation.fixMovedWindow(at: screenManager.mainFrame)
        presenter.fix(at: windowFrame)
    }
    
    /// SlideoVerを反対方向に移動する
    func reversePosition() {
        let windowFrame = slideOverComputation.reverseMoveWindow(at: screenManager.mainFrame)
        presenter.fix(at: windowFrame)
    }
    
    func requestResize(nextFrame: ObjectFrame) {
        guard let position = userSettingService.latestPosition else { return }
        let windowSize = position.state.computeResize(screenSize: screenManager.mainFrame.size, to: nextFrame.size)
        let windowFrame = ObjectFrame(from: NSRect(origin: nextFrame.origin, size: windowSize))
        let resizeWindowFrame = slideOverComputation.arrangeWindow(for: windowFrame, at: screenManager.mainFrame, type: position)
        presenter.fix(at: resizeWindowFrame)
    }
    
    /// 最後に読んだページとしてurlを保存する
    func memorizeLatestPage(url: URL?) {
        userSettingService.latestPage = url
    }
    
    /// 最後に移動させたポジションを保存する
    func memorizeLatestPosition(kind: SlideOverKind) {
        userSettingService.latestPosition = kind
    }
    
    /// ウィンドウサイズを保存する
    func memorizeLatestWindowSize(_ size: NSSize?) {
        userSettingService.latestWindowSize = size
    }
    
    /// 指定したユーザエージェントに切り替える
    func updateUserAgent(_ userAgent: UserAgent) {
        userSettingService.latestUserAgent = userAgent
        presenter.set(userAgent: userAgent)
    }

    /// 指定したポジションに移動させる
    func requestChangingPosition(type: SlideOverKind) {
        let windowFrame = slideOverComputation.fixWindow(at: screenManager.mainFrame, type: type)
        presenter.fix(at: windowFrame)
    }
    
    /// キャッシュを削除
    func clearCache() {
        webViewService.clearCache()
    }
    
    /// サーチバーにフォーカスする
    func focusSearchBar() {
        presenter.focusSearchBar()
    }
    
    /// ズームイン
    func zoomIn() {
        presenter.zoomIn()
    }
    
    /// ズームアウト
    func zoomOut() {
        presenter.zoomOut()
    }
    
    /// ズームリセット
    func zoomReset() {
        presenter.resetZoom()
    }
}
