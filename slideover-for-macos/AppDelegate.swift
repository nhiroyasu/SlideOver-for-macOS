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


}

