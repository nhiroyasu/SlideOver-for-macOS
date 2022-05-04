import Foundation

let marginTop: CGFloat = 32.0
let marginBottom: CGFloat = 32.0
let marginRight: CGFloat = 32.0
let marginLeft: CGFloat = 32.0
let hideOffsetSpace: CGFloat = 40.0

/// @mockable
protocol SlideOverComputable {
    func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect
    func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint
    func computeResize(from current: NSSize, to next: NSSize) -> NSSize
}

class SlideOver {
    class Vertical {
        let maxWidthSize: CGFloat = 512.0
        let minWidthSize: CGFloat = 384.0
        
        func computeWindowWidth(screenWidth: CGFloat) -> CGFloat {
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
        
        func computeResize(from current: NSSize, to next: NSSize) -> NSSize {
            var resultWidth = next.width
            if next.width > maxWidthSize {
                resultWidth = maxWidthSize
            }
            if next.width < minWidthSize {
                resultWidth = minWidthSize
            }
            return NSSize(width: resultWidth, height: current.height)
        }
    }
    
    class Left: Vertical, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect {
            let width = computeWindowWidth(screenWidth: screenSize.width)
            let height = computeWindowHeight(screenHeight: screenSize.height)
            let originX = computeOriginX(offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            let windowRect = CGRect(x: originX, y: originY, width: width, height: height)
            return windowRect
        }
        
        func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint {
            let originX = computeOriginX(offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            return CGPoint(x: originX, y: originY)
        }
        
        private func computeOriginX(offsetX: CGFloat) -> CGFloat {
            return marginLeft + offsetX
        }
        
        private func computeOriginY(offsetY: CGFloat) -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY + offsetY
        }
    }
    
    class Right: Vertical, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect {
            let width = computeWindowWidth(screenWidth: screenSize.width)
            let height = computeWindowHeight(screenHeight: screenSize.height)
            let originX = computeOriginX(windowWidth: width, screenWidth: screenSize.width, offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            let windowRect = CGRect(x: originX, y: originY, width: width, height: height)
            return windowRect
        }
        
        func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint {
            let originX = computeOriginX(windowWidth: windowSize.width, screenWidth: screenSize.width, offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            return CGPoint(x: originX, y: originY)
        }
        
        private func computeOriginX(windowWidth: CGFloat, screenWidth: CGFloat, offsetX: CGFloat) -> CGFloat {
            let bestOriginX: CGFloat = screenWidth - (windowWidth + marginRight) + offsetX
            return bestOriginX
        }
        
        private func computeOriginY(offsetY: CGFloat) -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY + offsetY
        }
    }
    
    class Rectangle {
        let aspectRatio: CGFloat = 16.0 / 9.0
        let minHeightSize: CGFloat = 384.0
        var minSize: CGSize {
            CGSize(width: minHeightSize * aspectRatio, height: minHeightSize)
        }

        func computeWindowSize(screenHeight: CGFloat) -> CGSize {
            let bestHeightSize: CGFloat = screenHeight / 2.0 - (marginTop + marginBottom)
            if bestHeightSize < minHeightSize {
                return minSize
            } else {
                let bestWidthSize = bestHeightSize * aspectRatio
                return CGSize(width: bestWidthSize, height: bestHeightSize)
            }
        }
        
        func computeResize(from current: NSSize, to next: NSSize) -> NSSize {
            var resultSize = NSSize(width: 0, height: 0)
            if current.width != next.width {
                resultSize = NSSize(width: next.width, height: next.width / aspectRatio)
            }
            if current.height != next.height {
                resultSize = NSSize(width: next.height * aspectRatio, height: next.height)
            }
            if resultSize.height < minHeightSize {
                return minSize
            } else {
                return resultSize
            }
        }
    }
    
    class TopLeft: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX(offsetX: screenOffset.x)
            let originY = computeOriginY(windowHeight: size.height, screenHeight: screenSize.height, offsetY: screenOffset.y)
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint {
            let originX = computeOriginX(offsetX: screenOffset.x)
            let originY = computeOriginY(windowHeight: windowSize.height, screenHeight: screenSize.height, offsetY: screenOffset.y)
            return CGPoint(x: originX, y: originY)
        }
        
        private func computeOriginX(offsetX: CGFloat) -> CGFloat {
            return marginLeft + offsetX
        }
        
        private func computeOriginY(windowHeight: CGFloat, screenHeight: CGFloat, offsetY: CGFloat) -> CGFloat {
            let bestOriginY = screenHeight - marginTop - windowHeight
            return bestOriginY + offsetY
        }
    }
    
    class TopRight: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX(windowWidth: size.width, screenWidth: screenSize.width, offsetX: screenOffset.x)
            let originY = computeOriginY(windowHeight: size.height, screenHeight: screenSize.height, offsetY: screenOffset.y)
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint {
            let originX = computeOriginX(windowWidth: windowSize.width, screenWidth: screenSize.width, offsetX: screenOffset.x)
            let originY = computeOriginY(windowHeight: windowSize.height, screenHeight: screenSize.height, offsetY: screenOffset.y)
            return CGPoint(x: originX, y: originY)
        }
        
        private func computeOriginX(windowWidth: CGFloat, screenWidth: CGFloat, offsetX: CGFloat) -> CGFloat {
            let bestOriginX: CGFloat = screenWidth - (windowWidth + marginRight) + offsetX
            return bestOriginX
        }
        
        private func computeOriginY(windowHeight: CGFloat, screenHeight: CGFloat, offsetY: CGFloat) -> CGFloat {
            let bestOriginY = screenHeight - marginTop - windowHeight
            return bestOriginY + offsetY
        }
    }
    
    class BottomLeft: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX(offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint {
            let originX = computeOriginX(offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            return CGPoint(x: originX, y: originY)
        }
        
        private func computeOriginX(offsetX: CGFloat) -> CGFloat {
            return marginLeft + offsetX
        }
        
        private func computeOriginY(offsetY: CGFloat) -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY + offsetY
        }
    }
    
    class BottomRight: Rectangle, SlideOverComputable {
        func computeWindowRect(screenSize: CGSize, screenOffset: CGPoint) -> CGRect {
            let size = computeWindowSize(screenHeight: screenSize.height)
            let originX = computeOriginX(windowWidth: size.width, screenWidth: screenSize.width, offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            let windowRect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            return windowRect
        }
        
        func computeWindowPoint(windowSize: CGSize, screenSize: CGSize, screenOffset: CGPoint) -> CGPoint {
            let originX = computeOriginX(windowWidth: windowSize.width, screenWidth: screenSize.width, offsetX: screenOffset.x)
            let originY = computeOriginY(offsetY: screenOffset.y)
            return CGPoint(x: originX, y: originY)
        }
        
        private func computeOriginX(windowWidth: CGFloat, screenWidth: CGFloat, offsetX: CGFloat) -> CGFloat {
            let bestOriginX: CGFloat = screenWidth - (windowWidth + marginRight) + offsetX
            return bestOriginX
        }
        
        private func computeOriginY(offsetY: CGFloat) -> CGFloat {
            let bestOriginY = marginBottom
            return bestOriginY + offsetY
        }
    }
}
