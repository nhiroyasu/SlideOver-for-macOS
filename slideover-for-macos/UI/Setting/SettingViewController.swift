import Cocoa
import Injectable

struct SwitchItemProps {
    let isOn: Bool
    let title: String
    let description: String
    let action: (Bool) -> Void
}

class SettingViewController: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView! {
        didSet {
            collectionView.register(Type: SwitchCell.self)
            collectionView.dataSource = self
            collectionView.collectionViewLayout = createLayout()
        }
    }
    var userSetting: UserSettingService?
    var alertService: AlertService?
    lazy var switchItems: [SwitchItemProps] = [
        .init(
            isOn: !(userSetting?.isNotAllowedGlobalShortcut ?? false),
            title: NSLocalizedString("⌘+⌃+s : hide window", comment: ""),
            description: NSLocalizedString("The 'Hide Window' function can be invoked by pressing ⌘ (command key), ^ (control key) and s (S key) simultaneously.", comment: ""),
            action: { [weak self] isOn in
                if isOn {
                    self?.userSetting?.isNotAllowedGlobalShortcut = false
                    self?.alertService?.alert(msg: NSLocalizedString("Please restart the application", comment: ""), completionHandler: {})
                } else {
                    self?.userSetting?.isNotAllowedGlobalShortcut = true
                    self?.alertService?.alert(msg: NSLocalizedString("Please restart the application", comment: ""), completionHandler: {})
                }
            }
        ),
        .init(
            isOn: !(userSetting?.isCompletelyHideWindow ?? false),
            title: NSLocalizedString("Show a little when 'Hide window'", comment: ""),
            description: NSLocalizedString("When the 'Hide Window' function is executed, a portion of the window remains on the screen.", comment: ""),
            action: { [weak self] isOn in
                if isOn {
                    self?.userSetting?.isCompletelyHideWindow = false
                } else {
                    self?.userSetting?.isCompletelyHideWindow = true
                }
            }
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userSetting = Injector.shared.buildSafe(UserSettingService.self)
        alertService = Injector.shared.buildSafe(AlertService.self)
    }
    
    func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(64.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension SettingViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        switchItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let view = collectionView.dequeueItem(Type: SwitchCell.self, for: indexPath)
        let item = switchItems[indexPath.item]
        view.set(SwitchCellViewData(switchState: item.isOn, title: item.title, description: item.description)) { isOn in
            item.action(isOn)
        }
        return view
    }
}
