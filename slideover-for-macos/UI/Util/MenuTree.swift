import Foundation

enum MenuItemType {
    case subMenu(data: MenuData)
    case item(data: MenuItemData)
    case separator
}

struct MenuData {
    let title: String
    let image: NSImage?
    let items: [MenuItemData]
    let customHandler: ((MenuItemData, NSMenuItem) -> Void)?
    
    internal init(title: String, image: NSImage?, items: [MenuItemData], customHandler: ((MenuItemData, NSMenuItem) -> Void)? = nil) {
        self.title = title
        self.image = image
        self.items = items
        self.customHandler = customHandler
    }
}

struct MenuItemData {
    let title: String
    let action: Selector?
    let keyEquivalent: String
    let keyEquivalentModify: NSEvent.ModifierFlags?
    let image: NSImage?
    let value: Any?
    
    internal init(
        title: String,
        action: Selector?,
        keyEquivalent: String,
        keyEquivalentModify: NSEvent.ModifierFlags? = nil,
        image: NSImage? = nil,
        value: Any? = nil
    ) {
        self.title = title
        self.action = action
        self.keyEquivalent = keyEquivalent
        self.keyEquivalentModify = keyEquivalentModify
        self.image = image
        self.value = value
    }
}

func buildMenu(from menuTree: [MenuItemType], for menu: NSMenu) {
    menuTree.forEach { type in
        switch type {
        case .separator:
            menu.addItem(.separator())
        case .item(let data):
            let item = NSMenuItem(title: data.title, action: data.action, keyEquivalent: data.keyEquivalent)
            if let modifyKey = data.keyEquivalentModify {
                item.keyEquivalentModifierMask = modifyKey
            }
            item.image = data.image
            item.image?.size = NSSize(width: 16, height: 16)
            menu.addItem(item)
        case .subMenu(let data):
            let subMenu = NSMenu(title: data.title)
            data.items.forEach { subMenuData in
                let item = NSMenuItem(title: subMenuData.title, action: subMenuData.action, keyEquivalent: subMenuData.keyEquivalent)
                if let modifyKey = subMenuData.keyEquivalentModify {
                    item.keyEquivalentModifierMask = modifyKey
                }
                item.image = subMenuData.image
                item.image?.size = NSSize(width: 16, height: 16)
                data.customHandler?(subMenuData, item)
                subMenu.addItem(item)
            }
            let subMenuItem = NSMenuItem(title: data.title, action: nil, keyEquivalent: "")
            subMenuItem.image = data.image
            subMenuItem.image?.size = NSSize(width: 16, height: 16)
            menu.addItem(subMenuItem)
            menu.setSubmenu(subMenu, for: subMenuItem)
        }
    }
}
