import Foundation
import XCTest
@testable import Fixture_in_Picture

class MousePointServiceTests: XCTestCase {
    
    func test_getHorizontalSplit_pattern1() {
        let subject = MousePointServiceImpl(point: .init(x: 49, y: 49), screenSize: .init(width: 100, height: 100))
        let result = subject.getHorizontalSplit()
        XCTAssertEqual(result, .left)
    }
    
    func test_getHorizontalSplit_pattern2() {
        let subject = MousePointServiceImpl(point: .init(x: 50, y: 50), screenSize: .init(width: 100, height: 100))
        let result = subject.getHorizontalSplit()
        XCTAssertEqual(result, .right)
    }
    
    func test_getVerticalSplit_pattern1() {
        let subject = MousePointServiceImpl(point: .init(x: 49, y: 49), screenSize: .init(width: 100, height: 100))
        let result = subject.getVerticalSplit()
        XCTAssertEqual(result, .top)
    }
    
    func test_getVerticalSplit_pattern2() {
        let subject = MousePointServiceImpl(point: .init(x: 50, y: 50), screenSize: .init(width: 100, height: 100))
        let result = subject.getVerticalSplit()
        XCTAssertEqual(result, .bottom)
    }
    
    func test_getHorizontalQuadSplit_pattern1() {
        let subject = MousePointServiceImpl(point: .init(x: 24, y: 24), screenSize: .init(width: 100, height: 100))
        let result = subject.getHorizontalQuadSplit()
        XCTAssertEqual(result, .first)
    }
    
    func test_getHorizontalQuadSplit_pattern2() {
        let subject = MousePointServiceImpl(point: .init(x: 49, y: 49), screenSize: .init(width: 100, height: 100))
        let result = subject.getHorizontalQuadSplit()
        XCTAssertEqual(result, .second)
    }
    
    func test_getHorizontalQuadSplit_pattern3() {
        let subject = MousePointServiceImpl(point: .init(x: 74, y: 74), screenSize: .init(width: 100, height: 100))
        let result = subject.getHorizontalQuadSplit()
        XCTAssertEqual(result, .third)
    }
    
    func test_getHorizontalQuadSplit_pattern4() {
        let subject = MousePointServiceImpl(point: .init(x: 100, y: 100), screenSize: .init(width: 100, height: 100))
        let result = subject.getHorizontalQuadSplit()
        XCTAssertEqual(result, .fourth)
    }
    
    func test_getVerticalQuadSplit_pattern1() {
        let subject = MousePointServiceImpl(point: .init(x: 24, y: 24), screenSize: .init(width: 100, height: 100))
        let result = subject.getVerticalQuadSplit()
        XCTAssertEqual(result, .first)
    }
    
    func test_getVerticalQuadSplit_pattern2() {
        let subject = MousePointServiceImpl(point: .init(x: 49, y: 49), screenSize: .init(width: 100, height: 100))
        let result = subject.getVerticalQuadSplit()
        XCTAssertEqual(result, .second)
    }
    
    func test_getVerticalQuadSplit_pattern3() {
        let subject = MousePointServiceImpl(point: .init(x: 74, y: 74), screenSize: .init(width: 100, height: 100))
        let result = subject.getVerticalQuadSplit()
        XCTAssertEqual(result, .third)
    }
    
    func test_getVerticalQuadSplit_pattern4() {
        let subject = MousePointServiceImpl(point: .init(x: 100, y: 100), screenSize: .init(width: 100, height: 100))
        let result = subject.getVerticalQuadSplit()
        XCTAssertEqual(result, .fourth)
    }
}
