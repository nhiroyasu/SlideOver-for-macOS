import Foundation
import AppKit

enum MousePoint {
    enum HalfHorizontal {
        case left
        case right
    }
    
    enum HalfVertical {
        case top
        case bottom
    }
    
    /// 最も左からfirst -> second ..
    enum QuadHorizontal {
        case first
        case second
        case third
        case fourth
    }
    
    /// 最も上からfirst -> second ..
    enum QuadVertical {
        case first
        case second
        case third
        case fourth
    }
}

protocol MousePointService {
    func getHorizontalSplit() -> MousePoint.HalfHorizontal
    func getVerticalSplit() -> MousePoint.HalfVertical
    func getHorizontalQuadSplit() -> MousePoint.QuadHorizontal
    func getVerticalQuadSplit() -> MousePoint.QuadVertical
}

class MousePointServiceImpl: MousePointService {
    
    static var current: MousePointServiceImpl? {
        guard let screenSize = NSScreen.main?.frame.size else { return nil }
        let mouseLocationReverse = CGPoint(x: NSEvent.mouseLocation.x, y: screenSize.height - NSEvent.mouseLocation.y)
        return .init(point: mouseLocationReverse, screenSize: screenSize)
    }
    
    private let point: CGPoint
    private let screenSize: CGSize
    
    init(point: CGPoint, screenSize: CGSize) {
        self.point = point
        self.screenSize = screenSize
    }
    
    func getHorizontalSplit() -> MousePoint.HalfHorizontal {
        let halfScreenWidth = screenSize.width / 2.0
        if point.x < halfScreenWidth {
            return .left
        } else {
            return .right
        }
    }
    
    func getVerticalSplit() -> MousePoint.HalfVertical {
        let halfScreenHeight = screenSize.height / 2.0
        if point.y < halfScreenHeight {
            return .top
        } else {
            return .bottom
        }
    }
    
    func getHorizontalQuadSplit() -> MousePoint.QuadHorizontal {
        if point.x < screenSize.width / 4.0 {
            return .first
        } else if point.x < screenSize.width / 2.0 {
            return .second
        } else if point.x < screenSize.width * (3.0 / 4.0) {
            return .third
        } else {
            return .fourth
        }
    }
    
    func getVerticalQuadSplit() -> MousePoint.QuadVertical {
        if point.y < screenSize.height / 4.0 {
            return .first
        } else if point.y < screenSize.height / 2.0 {
            return .second
        } else if point.y < screenSize.height * (3.0 / 4.0) {
            return .third
        } else {
            return .fourth
        }
    }
    
}