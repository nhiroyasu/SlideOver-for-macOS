import Foundation
import AppKit

enum SlideOverKind: Int {
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var state: SlideOverComputable {
        switch self {
        case .left:
            return SlideOver.Left()
        case .right:
            return SlideOver.Right()
        case .topLeft:
            return SlideOver.TopLeft()
        case .topRight:
            return SlideOver.TopRight()
        case .bottomLeft:
            return SlideOver.BottomLeft()
        case .bottomRight:
            return SlideOver.BottomRight()
        }
    }
}

/// @mockable
protocol SlideOverService {
    func fixWindow(for window: NSWindow, type: SlideOverKind)
    func fixMovedWindow(for window: NSWindow)
    func reverseMoveWindow(for window: NSWindow)
    func arrangeWindow(for window: NSWindow, type: SlideOverKind)
    func arrangeWindowPosition(for window: NSWindow, windowSize: NSSize, type: SlideOverKind)
    func hideWindow(for window: NSWindow, type: SlideOverKind) -> Bool
}

class SlideOverServiceImpl: SlideOverService {
    
    private var userSettingService: UserSettingService
    private var mousePointService: MousePointService? {
        MousePointServiceImpl.current
    }
    
    init(injector: Injectable) {
        self.userSettingService = injector.build(UserSettingService.self)
    }
    
    public func fixWindow(for window: NSWindow, type: SlideOverKind) {
        guard let screen = NSScreen.main else { return }
        userSettingService.latestPosition = type
        let windowRect = type.state.computeWindowRect(screenSize: screen.visibleFrame.size, screenOffset: screen.visibleFrame.origin)
        DispatchQueue.main.async {
            window.setFrame(windowRect, display: true, animate: true)
        }
    }
    
    func fixMovedWindow(for window: NSWindow) {
        guard let mousePointService = mousePointService else { return }
        
        if mousePointService.getHorizontalCornerSplit() == .left &&
            mousePointService.getVerticalCornerSplit() == .top {
            // 左上
            fixWindow(for: window, type: .topLeft)
        } else if mousePointService.getHorizontalCornerSplit() == .left &&
                    mousePointService.getVerticalCornerSplit() == .bottom {
            // 左下
            fixWindow(for: window, type: .bottomLeft)
        } else if mousePointService.getHorizontalCornerSplit() == .right &&
                    mousePointService.getVerticalCornerSplit() == .top {
            // 右上
            fixWindow(for: window, type: .topRight)
        } else if mousePointService.getHorizontalCornerSplit() == .right &&
                    mousePointService.getVerticalCornerSplit() == .bottom {
            // 右下
            fixWindow(for: window, type: .bottomRight)
        } else if mousePointService.getHorizontalSplit() == .left {
            // 左
            fixWindow(for: window, type: .left)
        } else if mousePointService.getHorizontalSplit() == .right {
            // 右
            fixWindow(for: window, type: .right)
        }
    }
    
    func reverseMoveWindow(for window: NSWindow) {
        switch userSettingService.latestPosition {
        case .left:
            fixWindow(for: window, type: .right)
        case .right:
            fixWindow(for: window, type: .left)
        case .topLeft:
            fixWindow(for: window, type: .topRight)
        case .topRight:
            fixWindow(for: window, type: .topLeft)
        case .bottomLeft:
            fixWindow(for: window, type: .bottomRight)
        case .bottomRight:
            fixWindow(for: window, type: .bottomLeft)
        case .none:
            break
        }
    }
    
    func arrangeWindow(for window: NSWindow, type: SlideOverKind) {
        guard let screen = NSScreen.main else { return }
        let windowPoint = type.state.computeWindowPoint(windowSize: window.frame.size, screenSize: screen.visibleFrame.size, screenOffset: screen.visibleFrame.origin)
        let windowRect = NSRect(origin: windowPoint, size: window.frame.size)
        DispatchQueue.main.async {
            window.setFrame(windowRect, display: true, animate: true)
        }
    }
    
    func arrangeWindowPosition(for window: NSWindow, windowSize: NSSize, type: SlideOverKind) {
        guard let screen = NSScreen.main else { return }
        let windowPoint = type.state.computeWindowPoint(windowSize: windowSize, screenSize: screen.visibleFrame.size, screenOffset: screen.visibleFrame.origin)
        DispatchQueue.main.async {
            window.setFrameOrigin(windowPoint)
        }
    }
    
    func hideWindow(for window: NSWindow, type: SlideOverKind) -> Bool {
        switch type {
        case .left, .topLeft, .bottomLeft:
            let size = window.frame.size
            let prevPoint = window.frame.origin
            let windowPoint = NSPoint(x: prevPoint.x - size.width - marginRight + hideOffsetSpace, y: prevPoint.y)
            let nextWindowFrame = NSRect(origin: windowPoint, size: size)
            if canSetFrame(nextFrame: nextWindowFrame) {
                DispatchQueue.main.async {
                    window.setFrame(nextWindowFrame, display: true, animate: true)
                }
                return true
            } else {
                NSSound.beep()
                return false
            }
        case .right, .topRight, .bottomRight:
            let size = window.frame.size
            let prevPoint = window.frame.origin
            let windowPoint = NSPoint(x: prevPoint.x + size.width + marginRight - hideOffsetSpace, y: prevPoint.y)
            let nextWindowFrame = NSRect(origin: windowPoint, size: size)
            if canSetFrame(nextFrame: nextWindowFrame) {
                DispatchQueue.main.async {
                    window.setFrame(nextWindowFrame, display: true, animate: true)
                }
                return true
            } else {
                NSSound.beep()
                return false
            }
        }
    }
    
    private func canSetFrame(nextFrame: NSRect) -> Bool {
        // NOTE: 移動先のFrameが二つ以上のスクリーンに重なっており、Originがどのスクリーンにも含まれない場合、setFrameができない可能性あり
        let isIntersectsTwoScreen = NSScreen.screens.filter { screen in screen.frame.intersects(nextFrame) }.count >= 2
        let isNotContainAllScreen = NSScreen.screens.allSatisfy { screen in screen.frame.contains(nextFrame.origin) == false }
        return !(isIntersectsTwoScreen && isNotContainAllScreen)
    }
}

