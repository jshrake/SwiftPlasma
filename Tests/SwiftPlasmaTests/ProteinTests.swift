import XCTest

@testable import SwiftPlasma

final class ProteinTests: XCTestCase {
  func testAsMap() {
    let p = Protein(descrips: ["hello"], ingests: ["name": "world"])
    let _: [String: Any] = p.asMap()
  }
}
