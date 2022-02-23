import Foundation

fileprivate let marginTop: CGFloat = 64.0
fileprivate let marginBottom: CGFloat = 64.0
fileprivate let marginRight: CGFloat = 64.0

protocol SlideOverComputable {
    func computeWindowRect(screenSize: CGSize) -> CGRect
}

class SlideOver {
    class Vertical {
        func computeWindowWidth(screenWidth: CGFloat) -> CGFloat {
            let maxWidthSize: CGFloat = 512.0
            let minWidthSize: CGFloat = 384.0
            
            let tempWidthSize: CGFloat = screenWidth / 6.0
            
            var bestWidthSize: CGFloat = tempWidthSize
            bestWidthSize = .maximum(bestWidthSize, minWidthSize)
            bestWidthSize = .minimum(bestWidthSize, maxWidthSize)
            
            return bestWidthSize
        }
        
        func computeWindowHeight(screenHeight: CGFloat) -> CGFloat {
            let bestHeightSize: CGFloat = screenHeight - (marginTop + marginBottom)
            return bestHeightSize
        }
    }
    
    class Left: Vertical, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize) -> CGRect {
            let width = computeWindowWidth(screenWidth: screenSize.width)
            let height = computeWindowHeight(screenHeight: screenSize.height)
            let originX = computeOriginX()
            let originY = computeOriginY()
            let windowRect = CGRect(x: originX, y: originY, width: width, height: height)
            return windowRect
        }
        
        private func computeOriginX() -> CGFloat {
            let marginLeft: CGFloat = 64.0
            return marginLeft
        }
        
        private func computeOriginY() -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY
        }
    }
    
    class Right: Vertical, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize) -> CGRect {
            let width = computeWindowWidth(screenWidth: screenSize.width)
            let height = computeWindowHeight(screenHeight: screenSize.height)
            let originX = computeOriginX(windowWidth: width, screenWidth: screenSize.width)
            let originY = computeOriginY()
            let windowRect = CGRect(x: originX, y: originY, width: width, height: height)
            return windowRect
        }
        
        private func computeOriginX(windowWidth: CGFloat, screenWidth: CGFloat) -> CGFloat {
            let marginRight: CGFloat = 64.0
            let bestOriginX: CGFloat = screenWidth - (windowWidth + marginRight)
            return bestOriginX
        }
        
        private func computeOriginY() -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY
        }
    }
    
    class Rectangle {
        private let aspectRatio: CGFloat = 16.0 / 9.0

        func computeWindowSize(screenHeight: CGFloat) -> CGSize {
            let bestHeightSize: CGFloat = screenHeight / 2.0 - (marginTop + marginBottom)
            let bestWidthSize = bestHeightSize * aspectRatio
            return CGSize(width: bestWidthSize, height: bestHeightSize)
        }
    }
    
    class TopLeft: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX()
            let originY = computeOriginY(windowHeight: size.height, screenHeight: screenSize.height)
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        private func computeOriginX() -> CGFloat {
            let marginLeft: CGFloat = 64.0
            return marginLeft
        }
        
        private func computeOriginY(windowHeight: CGFloat, screenHeight: CGFloat) -> CGFloat {
            let bestOriginY = screenHeight / 2.0 + marginBottom
            return bestOriginY
        }
    }
    
    class TopRight: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX(windowWidth: size.width, screenWidth: screenSize.width)
            let originY = computeOriginY(windowHeight: size.height, screenHeight: screenSize.height)
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        private func computeOriginX(windowWidth: CGFloat, screenWidth: CGFloat) -> CGFloat {
            let marginRight: CGFloat = 64.0
            let bestOriginX: CGFloat = screenWidth - (windowWidth + marginRight)
            return bestOriginX
        }
        
        private func computeOriginY(windowHeight: CGFloat, screenHeight: CGFloat) -> CGFloat {
            let bestOriginY = screenHeight / 2.0 + marginBottom
            return bestOriginY
        }
    }
    
    class BottomLeft: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX()
            let originY = computeOriginY()
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        private func computeOriginX() -> CGFloat {
            let marginLeft: CGFloat = 64.0
            return marginLeft
        }
        
        private func computeOriginY() -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY
        }
    }
    
    class BottomRight: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX(windowWidth: size.width, screenWidth: screenSize.width)
            let originY = computeOriginY()
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        private func computeOriginX(windowWidth: CGFloat, screenWidth: CGFloat) -> CGFloat {
            let marginRight: CGFloat = 64.0
            let bestOriginX: CGFloat = screenWidth - (windowWidth + marginRight)
            return bestOriginX
        }
        
        private func computeOriginY() -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY
        }
    }
}
