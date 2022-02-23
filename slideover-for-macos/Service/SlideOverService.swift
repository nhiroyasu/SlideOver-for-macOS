import Foundation
import AppKit

enum SlideOverKind {
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

protocol SlideOverService {
    func fixWindow(for window: NSWindow, type: SlideOverKind)
    func fixMovedWindow(for window: NSWindow)
}

class SlideOverServiceImpl: SlideOverService {
    
    private var mousePointService: MousePointService? {
        MousePointServiceImpl.current
    }
    
    public func fixWindow(for window: NSWindow, type: SlideOverKind) {
        guard let screen = NSScreen.main else { return }
        let windowRect = type.state.computeWindowRect(screenSize: screen.frame.size)
        DispatchQueue.main.async {
            window.setFrame(windowRect, display: true, animate: true)
        }
    }
    
    func fixMovedWindow(for window: NSWindow) {
        guard let mousePointService = mousePointService else { return }
        
        if mousePointService.getHorizontalQuadSplit() == .first &&
            mousePointService.getVerticalQuadSplit() == .first {
            // 左上
            fixWindow(for: window, type: .topLeft)
        } else if mousePointService.getHorizontalQuadSplit() == .first &&
                    mousePointService.getVerticalQuadSplit() == .fourth {
            // 左下
            fixWindow(for: window, type: .bottomLeft)
        } else if mousePointService.getHorizontalQuadSplit() == .fourth &&
                    mousePointService.getVerticalQuadSplit() == .first {
            // 右上
            fixWindow(for: window, type: .topRight)
        } else if mousePointService.getHorizontalQuadSplit() == .fourth &&
                    mousePointService.getVerticalQuadSplit() == .fourth {
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
}
