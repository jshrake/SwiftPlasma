import Plasma
import XCTest

@testable import SwiftPlasma

final class SlawTests: XCTestCase {
  func testStringRoundtrip() {
    let i = "hello"
    let slaw = Slaw(i)
    let s: String = slaw.emit()!
    XCTAssert(i == s)
  }

  func testIntRoundTrip() {
    let i = 42
    let s = Slaw(i)
    let o: Int = s.emit()!
    XCTAssert(s.isNumeric())
    XCTAssert(i == o)
  }

  func testIntArrayRoundtrip() {
    let i = [1, 2, 3]
    let s = Slaw(i)
    let o: [Int] = s.emit()!
    XCTAssert(s.isNumericArray())
    XCTAssert(i == o)
  }

  func testAnyArrayRoundtrip() {
    let i: [Any] = ["hello", 1, 3.3, ["ok", 5, false], true]
    let s = Slaw(i)
    let o: [Any] = s.emit()!
    XCTAssert(s.isList())
    XCTAssert(i.count == o.count)
    XCTAssert(i[0] as! String == o[0] as! String)
    // Rough edge. We lose the input type
    XCTAssert(i[1] as! Int == o[1] as! Int64)
    XCTAssert(i[2] as! Double == o[2] as! Double)
    XCTAssert((i[3] as! [Any]).count == (o[3] as! [Any]).count)
  }

  func testAnyArray() {
    let i: [Any] = [1, 2, 3.0, ["hello", 1, 2, false, ["a": "b", "c": [3.0, 5, "ok"]]]]
    let s = Slaw(i)
    let o: [Any] = s.emit()!
    let _ = try! s.toYamlString().get()
    XCTAssert(s.isList())
    XCTAssert(i.count == o.count)
  }

  func testAnyMap() {
    let i: [String: Any] = ["a": 1.0, "b": 2, "c": "hello", "d": ["a": "b", "c": [3.0, 5, "ok"]]]
    let s = Slaw(i)
    let o: [String: Any] = s.emit()!
    let _ = try! s.toYamlString().get()
    XCTAssert(s.isMap())
    XCTAssert(i.count == o.count)
  }

  func testMap() {
    let i: [String: Int64] = ["size": 1024]
    let s = Slaw(i)
    let o: [String: Int64] = s.emit()!
    XCTAssert(i == o)
    XCTAssert(s.isMap())
  }
}
