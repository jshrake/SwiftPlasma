import XCTest

@testable import SwiftPlasma

final class ProteinTests: XCTestCase {
  func testAsMap() {
    let p = Protein(descrips: ["hello"], ingests: ["name": "world"])
    let _: [String: Any] = p.asMap()
  }

  func testCreation() {
    let p = Protein(
      descrips: ["raycast"], ingests: ["origin": [0.0, 0.0, 5.0], "direction": [0.0, 0.0, -1.0]])
    let m = p.asMap()
    print(m)
  }
}
