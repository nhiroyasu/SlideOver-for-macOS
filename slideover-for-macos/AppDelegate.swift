import Cocoa
import Magnet
import Injectable

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var notificationManager: NotificationManager? {
        Injector.shared.buildSafe(NotificationManager.self)
    }
    private var userSetting: UserSettingService? {
        Injector.shared.buildSafe(UserSettingService.self)
    }
    private var slideOverCoordinator: SlideOverCoordinator!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let initState = SlideOverState()
        let container = SlideOverContainerBuilder.build(parent: Injector.shared.container, state: initState)
        slideOverCoordinator = .init(
            injector: Injector(container: container),
            state: initState
        )
        container.register(SlideOverTransition.self) { _ in self.slideOverCoordinator }
        let windowController = slideOverCoordinator.create()
        windowController.showWindow(self)
    }
    
    func applicationDidUnhide(_ notification: Notification) {
        notificationManager?.push(name: .displaySlideOver, param: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let urlItem = components?.queryItems?.first(where: { item in
            item.name == "url"
        }) else { return }
        guard let targetUrl = urlItem.value else { return }
        notificationManager?.push(name: .openUrl, param: targetUrl)
        if var userSetting = userSetting {
            userSetting.latestPage = URL(string: targetUrl)
        }
    }

    @IBAction func didTapReloadButton(_ sender: Any) {
        notificationManager?.push(name: .reload, param: nil)
    }
    
    @IBAction func didTapCacheClearItem(_ sender: Any) {
        notificationManager?.push(name: .clearCache, param: nil)
    }
    
    @IBAction func didTapHelpItem(_ sender: Any) {
        notificationManager?.push(name: .openHelp, param: nil)
    }
    
    @IBAction func didTapSearchItem(_ sender: Any) {
        notificationManager?.push(name: .searchFocus, param: nil)
    }
    
    @IBAction func didTapHideWindowItem(_ sender: Any) {
        notificationManager?.push(name: .hideWindow, param: nil)
    }
    
    @IBAction func didTapLicenseItem(_ sender: Any) {
        notificationManager?.push(name: .openUrlForBrowser, param: "https://nhiro.notion.site/Fixture-in-Picture-License-10d29166c48d44bcba28e828afaaa667")
    }
    
    @IBAction func didTapZoomInItem(_ sender: Any) {
        notificationManager?.push(name: .zoomInWebView, param: nil)
    }
    
    @IBAction func didTapZoomOutItem(_ sender: Any) {
        notificationManager?.push(name: .zoomOutWebView, param: nil)
    }
    
    @IBAction func didTapZoomResetItem(_ sender: Any) {
        notificationManager?.push(name: .zoomResetWebView, param: nil)
    }
}
