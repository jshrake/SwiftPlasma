import XCTest
@testable import SwiftPlasma

final class SwiftPlasmaTests: XCTestCase {
    func testExample() throws {
        let p = Protein(descrips: ["hello"], ingests: ["name": "world"])
        let poolName = "test"
        let options = PoolCreateOptions(size: 2048)
        try! Pool.create(addr: poolName, options: options).get()
        let pool = try! Pool.participate(addr: poolName).get()
        let ok = pool.deposit(p)
        XCTAssert(ok == Retort.Ok, "deposit failed")
    }
}
