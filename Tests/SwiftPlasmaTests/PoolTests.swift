import XCTest

@testable import SwiftPlasma

final class SwiftPlasmaTests: XCTestCase {
  func testParticipateDepositLocalPool() throws {
    let p = Protein(descrips: ["hello"], ingests: ["name": "world"])
    let poolName = "test"
    let options = PoolCreateOptions(size: 2048)
    let hose = try! Pool.participate(name: poolName, create: options).get()
    let tort = hose.deposit(p)
    XCTAssert(tort.isOk, "deposit failed")
  }
}
