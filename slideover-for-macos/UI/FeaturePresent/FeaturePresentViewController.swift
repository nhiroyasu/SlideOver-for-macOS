import Cocoa
import Injectable

class FeaturePresentViewController: NSViewController {
    
    var notificationManager: NotificationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationManager = Injector.shared.buildSafe(NotificationManager.self)
    }
    
    @IBAction func didTapShowDetailButton(_ sender: Any) {
        notificationManager?.push(name: .openUrlForBrowser, param: "https://nhiro.notion.site/v1-4-0-876e4592d49c4b5eb3180ecb6a90103d#b8c077ed94fd4548b39e8b0f9fcb06dc")
    }
    
    @IBAction func didTapOKButton(_ sender: Any) {
        view.window?.close()
    }
}
