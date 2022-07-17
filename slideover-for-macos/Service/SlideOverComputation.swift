import Foundation
import AppKit
import Injectable

struct ObjectFrame {
    let frame: NSRect
    let size: NSSize
    let origin: NSPoint
    
    init(from rect: NSRect) {
        self.frame = rect
        self.size = rect.size
        self.origin = rect.origin
    }
    
    init(from size: NSSize) {
        self.frame = NSRect(origin: .zero, size: size)
        self.size = size
        self.origin = .zero
    }
}

/// @mockable
protocol SlideOverComputation {
    /// 指定したポジションに配置される場合のウィンドウフレームを計算する
    func fixWindow(at screen: ObjectFrame, type: SlideOverKind) -> NSRect
    /// 移動されたウィンドウに対して、適切なウィンドウフレームを計算する（実際はマウスの位置から計算する）
    func fixMovedWindow(at screen: ObjectFrame) -> NSRect
    /// 反対方向に移動した場合のウィンドウフレームを計算する
    func reverseMoveWindow(at screen: ObjectFrame) -> NSRect
    /// ウィンドウが指定したポジションに配置される場合のウィンドウフレームを計算
    func arrangeWindow(for window: ObjectFrame, at screen: ObjectFrame, type: SlideOverKind) -> NSRect
    /// ウィンドウが指定したポジションに配置される場合のウィンドウフレームを計算。ただし、ウィンドウサイズは引数が優先される
//    func arrangeWindow(for window: ObjectFrame, windowSize: NSSize, type: SlideOverKind) -> NSRect
//    func arrangeWindowPosition(for window: WindowFrame, windowSize: NSSize, type: SlideOverKind) -> NSRect
    /// 外側にウィンドウを隠す場合のウィンドウフレームを計算
    func disappearOutside(for window: ObjectFrame, type: SlideOverKind) -> NSRect
    /// 完全にウィンドウを隠す場合のウィンドウフレームを計算
    func disappearCompletely(for window: ObjectFrame, type: SlideOverKind) -> NSRect
}

class SlideOverComputationImpl: SlideOverComputation {
    private var userSettingService: UserSettingService
    private var mousePointService: MousePointService? {
        MousePointServiceImpl.current
    }
    
    init(injector: Injectable) {
        self.userSettingService = injector.build(UserSettingService.self)
    }
    
    public func fixWindow(at screen: ObjectFrame, type: SlideOverKind) -> NSRect {
        userSettingService.latestPosition = type
        let windowRect = type.state.computeWindowRect(screenSize: screen.size, screenOffset: screen.origin)
        return windowRect
    }
    
    func fixMovedWindow(at screen: ObjectFrame) -> NSRect {
        guard let mousePointService = mousePointService else { return .zero }
        
        if mousePointService.getHorizontalCornerSplit() == .left &&
            mousePointService.getVerticalCornerSplit() == .top {
            // 左上
            return fixWindow(at: screen, type: .topLeft)
        } else if mousePointService.getHorizontalCornerSplit() == .left &&
                    mousePointService.getVerticalCornerSplit() == .bottom {
            // 左下
            return fixWindow(at: screen, type: .bottomLeft)
        } else if mousePointService.getHorizontalCornerSplit() == .right &&
                    mousePointService.getVerticalCornerSplit() == .top {
            // 右上
            return fixWindow(at: screen, type: .topRight)
        } else if mousePointService.getHorizontalCornerSplit() == .right &&
                    mousePointService.getVerticalCornerSplit() == .bottom {
            // 右下
            return fixWindow(at: screen, type: .bottomRight)
        } else if mousePointService.getHorizontalSplit() == .left {
            // 左
            return fixWindow(at: screen, type: .left)
        } else if mousePointService.getHorizontalSplit() == .right {
            // 右
            return fixWindow(at: screen, type: .right)
        }
        
        return .zero
    }
    
    func reverseMoveWindow(at screen: ObjectFrame) -> NSRect {
        switch userSettingService.latestPosition {
        case .left:
            return fixWindow(at: screen, type: .right)
        case .right:
            return fixWindow(at: screen, type: .left)
        case .topLeft:
            return fixWindow(at: screen, type: .topRight)
        case .topRight:
            return fixWindow(at: screen, type: .topLeft)
        case .bottomLeft:
            return fixWindow(at: screen, type: .bottomRight)
        case .bottomRight:
            return fixWindow(at: screen, type: .bottomLeft)
        case .none:
            return .zero
        }
    }
    
    func arrangeWindow(for window: ObjectFrame, at screen: ObjectFrame, type: SlideOverKind) -> NSRect {
        let windowPoint = type.state.computeWindowPoint(windowSize: window.frame.size, screenSize: screen.size, screenOffset: screen.origin)
        let windowRect = NSRect(origin: windowPoint, size: window.frame.size)
        return windowRect
    }
    
//    func arrangeWindow(for window: ObjectFrame, windowSize: NSSize, type: SlideOverKind) -> NSRect {
//        guard let screen = NSScreen.main else { return window.frame }
//        let windowPoint = type.state.computeWindowPoint(windowSize: windowSize, screenSize: screen.visibleFrame.size, screenOffset: screen.visibleFrame.origin)
//        let windowRect = NSRect(origin: windowPoint, size: windowSize)
//        return windowRect
//    }
    
//    func arrangeWindowPosition(for window: WindowFrame, windowSize: NSSize, type: SlideOverKind) -> NSRect {
//        guard let screen = NSScreen.main else { return window.frame }
//        let windowPoint = type.state.computeWindowPoint(windowSize: windowSize, screenSize: screen.visibleFrame.size, screenOffset: screen.visibleFrame.origin)
//        return NSRect(origin: windowPoint, size: windowSize)
//    }
    
    func disappearOutside(for window: ObjectFrame, type: SlideOverKind) -> NSRect {
        switch type {
        case .left, .topLeft, .bottomLeft:
            let size = window.frame.size
            let prevPoint = window.frame.origin
            let windowPoint = NSPoint(x: prevPoint.x - size.width - marginRight + hideOffsetSpace, y: prevPoint.y)
            let nextWindowFrame = NSRect(origin: windowPoint, size: size)
            if canSetFrame(nextFrame: nextWindowFrame) {
                return nextWindowFrame
            } else {
                NSSound.beep()
                return window.frame
            }
        case .right, .topRight, .bottomRight:
            let size = window.frame.size
            let prevPoint = window.frame.origin
            let windowPoint = NSPoint(x: prevPoint.x + size.width + marginRight - hideOffsetSpace, y: prevPoint.y)
            let nextWindowFrame = NSRect(origin: windowPoint, size: size)
            if canSetFrame(nextFrame: nextWindowFrame) {
                return nextWindowFrame
            } else {
                NSSound.beep()
                return window.frame
            }
        }
    }
    
    func disappearCompletely(for window: ObjectFrame, type: SlideOverKind) -> NSRect {
        let prevSize = window.frame.size
        let prevPoint = window.frame.origin
        
        switch type {
        case .right, .topRight, .bottomRight:
            let nextWindowPoint = NSPoint(x: prevPoint.x + prevSize.width, y: prevPoint.y)
            let nextWindowFrame = NSRect(origin: nextWindowPoint, size: NSSize(width: 0, height: prevSize.height))
            return nextWindowFrame
        case .left, .topLeft, .bottomLeft:
            let nextWindowPoint = NSPoint(x: prevPoint.x, y: prevPoint.y)
            let nextWindowFrame = NSRect(origin: nextWindowPoint, size: NSSize(width: 0, height: prevSize.height))
            return nextWindowFrame
        }
    }
    
    private func canSetFrame(nextFrame: NSRect) -> Bool {
        // NOTE: 移動先のFrameが二つ以上のスクリーンに重なっており、Originがどのスクリーンにも含まれない場合、setFrameができない可能性あり
        let isIntersectsTwoScreen = NSScreen.screens.filter { screen in screen.frame.intersects(nextFrame) }.count >= 2
        let isNotContainAllScreen = NSScreen.screens.allSatisfy { screen in screen.frame.contains(nextFrame.origin) == false }
        return !(isIntersectsTwoScreen && isNotContainAllScreen)
    }
}

