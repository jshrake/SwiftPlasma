// The Swift Programming Language
// https://docs.swift.org/swift-book

import Plasma

public struct PoolCreateOptions {
  let size: Int
}

public struct Pool {
  public static func create(name: String, options: PoolCreateOptions) -> Result<(), Retort> {
    tort {
      let slaw = Slaw(["size": options.size])
      return pool_create(name, "mmap", slaw.slaw)
    }
  }

  public static func dispose(name: String) -> Result<(), Retort> {
    tort {
      pool_dispose(name)
    }
  }

  public static func participate(name: String, options: PoolCreateOptions? = nil) -> Result<
    Hose, Retort
  > {
    var hose: pool_hose? = nil
    var tort: Retort
    if let create = options {
      let createSlaw = Protein(ingests: ["size": create.size])
      tort = Retort(
        pool_participate_creatingly(
          name, "mmap", &hose, createSlaw.slaw))
    } else {
      tort = Retort(pool_participate(name, &hose, nil))
    }
    // let options = Slaw(["size": options?.size ?? 0])
    // let tort = Retort(
    //   pool_participate_creatingly(
    //     addr, "mmap", &hose, options.slaw))
    if tort.isOk && hose != nil {
      return .success(Hose(hose: hose!))
    } else {
      return .failure(tort)
    }
  }
}

public class Hose {
  let hose: pool_hose

  deinit {
    pool_withdraw(hose)
  }

  public init(hose: pool_hose) {
    self.hose = hose
  }

  public func deposit(_ p: Protein) -> Retort {
    let ok = pool_deposit(hose, p.slaw, nil)
    return Retort(ok)
  }

  public func oldestIdx() -> Int64 {
    var idx: Int64 = -1
    pool_oldest_index(hose, &idx)
    return idx
  }

  public func newestIdx() -> Int64 {
    var idx: Int64 = -1
    pool_newest_index(hose, &idx)
    return idx
  }

  public func currentIdx() -> Int64 {
    var idx: Int64 = -1
    pool_index(hose, &idx)
    return idx
  }

  public func currentProtein() -> Result<Protein, Error> {
    var protein: protein? = nil
    var timestamp: pool_timestamp = 0
    let ok = pool_curr(hose, &protein, &timestamp)
    if ok == Retort.ok.rawValue {
      return .success(Protein(protein: protein!, timestamp: timestamp))
    } else {
      return .failure(Retort(ok))
    }
  }
}
