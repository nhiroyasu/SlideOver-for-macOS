//
//  AppDelegate.swift
//  slideover-for-macos
//
//  Created by NH on 2022/02/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var mainWindowController: SlideOverWindowController?
    private var notificationManager: NotificationManager? {
        Injector.shared.buildSafe(NotificationManager.self)
    }
    private var userSetting: UserSettingService? {
        Injector.shared.buildSafe(UserSettingService.self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        mainWindowController = storyboard.instantiateController(identifier: "slideOverWindowController") { coder in
            SlideOverWindowController(coder: coder, injector: Injector.shared)
        }
        if let mainWindowController = mainWindowController {
            Injector.shared.container.register(SlideOverWindowControllable.self, impl: mainWindowController).inObjectScope(.container)
            mainWindowController.showWindow(self)
        }
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
}

