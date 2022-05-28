import Cocoa

class FeaturePresentViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapShowDetailButton(_ sender: Any) {
        guard let url = URL(string: "https://nhiro.notion.site/v1-4-0-876e4592d49c4b5eb3180ecb6a90103d#b8c077ed94fd4548b39e8b0f9fcb06dc") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func didTapOKButton(_ sender: Any) {
        view.window?.close()
    }
}
