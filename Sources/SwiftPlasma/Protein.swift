import Foundation
import Plasma

public struct Protein {
  let protein: Slaw
  /// The date the protein was created, if read from a Pool.
  let date: Date

  public init(protein: protein, timestamp: pool_timestamp = 0) {
    assert(slaw_is_protein(protein))
    self.protein = Slaw(protein)
    self.date = Date(timeIntervalSince1970: timestamp)
  }

  public init(protein: Slaw, timestamp: pool_timestamp = 0) {
    self.init(protein: protein.slaw, timestamp: timestamp)
  }

  public init(descrips: slaw, ingests: slaw, rude: [UInt8] = [], timestamp: pool_timestamp = 0) {
    let protein = protein_from_llr(descrips, ingests, rude, Int64(rude.count))!
    self.init(protein: protein)
  }

  public init(descrips: BSlaw, ingests: BSlaw, rude: [UInt8] = [], timestamp: pool_timestamp = 0) {
    self.init(descrips: descrips.slaw, ingests: ingests.slaw, rude: rude)
  }

  public init(
    descrips: [String], ingests: [String: Any], rude: [UInt8] = [], timestamp: pool_timestamp = 0
  ) {
    // TODO(jshrake): Can we allocate BSlaw here instead? Concerned about leaking memory.
    // I think Slaw is the right choice, but leaving this comment here for the future.
    let descrips = Slaw(descrips)
    let ingests = Slaw(ingests)
    self.init(descrips: descrips, ingests: ingests, rude: rude)
  }

  public init(
    ingests: [String: Any], rude: [UInt8] = [], timestamp: pool_timestamp = 0
  ) {
    // TODO(jshrake): Can we allocate BSlaw here instead? Concerned about leaking memory.
    // I think Slaw is the right choice, but leaving this comment here for the future.
    let ingests = Slaw(ingests)
    self.init(descrips: slaw_nil(), ingests: ingests.slaw, rude: rude)
  }

  public func descrips() -> BSlaw {
    BSlaw(protein_descrips(self.slaw))
  }

  public func ingests() -> BSlaw {
    BSlaw(protein_ingests(self.slaw))
  }

  public func rude() -> [UInt8] {
    var count: Int64 = 0
    if let rude = protein_rude(self.slaw, &count) {
      let typedRude = rude.assumingMemoryBound(to: UInt8.self)
      let buffer = UnsafeBufferPointer(start: typedRude, count: Int(count))
      return Array(buffer)
    } else {
      return []
    }
  }

  public var slaw: slaw {
    self.protein.slaw
  }
}
