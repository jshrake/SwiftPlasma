// The Swift Programming Language
// https://docs.swift.org/swift-book

import Plasma

public struct PoolCreateOptions {
  let size: Int
}

public enum ProteinWait {
  case forever
  case seconds(Double)
}

public struct Pool {
  public static func list(address: String) -> Result<[String], Retort> {
    var slaw: slaw? = nil
    let tort = pool_list_ex(address, &slaw)
    if tort == Retort.ok.rawValue && slaw != nil {
      let val: [String] = Slaw(slaw!).emit()!
      return .success(val)
    } else {
      return .failure(Retort(tort))
    }
  }
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

  public static func participate(name: String, create: PoolCreateOptions? = nil) -> Result<
    Hose, Retort
  > {
    var hose: pool_hose? = nil
    var tort: Retort
    if let create = create {
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

  public static func disableAtForkHandlers() {
    pool_disable_atfork_handlers()
  }

  public static func enableAtForkHandlers() {
    pool_enable_atfork_handlers()
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

  /// The optional name of the hose, useful for debugging.
  public var name: String? {
    get {
      let n = pool_get_hose_name(self.hose)
      if let n = n {
        return String(cString: n)
      }
      return nil
    }
    set {
      pool_set_hose_name(self.hose, newValue)
    }
  }

  /// Returns the name of the pool that the hose is connected to.
  public func poolName() -> String? {
    let name = pool_name(self.hose)
    if let name = name {
      return String(cString: name)
    }
    return nil
  }

  /// Deposits a protein into the pool.
  public func deposit(_ p: Protein) -> Retort {
    let ok = pool_deposit(hose, p.slaw, nil)
    return Retort(ok)
  }

  /// Retrieve the index of the oldest protein in the pool.
  public func oldestIdx() -> Int64 {
    var idx: Int64 = -1
    pool_oldest_index(hose, &idx)
    return idx
  }

  /// Retrieve the index of the newest protein in the pool.
  public func newestIdx() -> Int64 {
    var idx: Int64 = -1
    pool_newest_index(hose, &idx)
    return idx
  }

  /// Retrieve the current index of the hose.
  public func currentIdx() -> Int64 {
    var idx: Int64 = -1
    pool_index(hose, &idx)
    return idx
  }

  /// Set the pool hose's index to the first available protein.
  public func rewind() -> Retort {
    let ok = pool_rewind(hose)
    return Retort(ok)
  }

  /// Set the pool hose's index to the last available protein.
  public func tolast() -> Retort {
    let ok = pool_tolast(hose)
    return Retort(ok)
  }

  /// Set the pool hose's index to the one past the last available protein.
  public func runout() -> Retort {
    let ok = pool_tolast(hose)
    return Retort(ok)
  }

  /// Move the pool hose's index forward or backward by the given offset.
  public func offsetBy(offset: Int64) -> Retort {
    let ok =
      if offset > 0 {
        pool_frwdby(hose, offset)
      } else {
        pool_backby(hose, -offset)
      }
    return Retort(ok)
  }

  /// Set the pool hose's index to the given index.
  public func seekTo(idx: Int64) -> Retort {
    let ok = pool_seekto(hose, idx)
    return Retort(ok)
  }

  /// Retrieve the protein at the current hose index.
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

  /// Retrieve the protein with the given index.
  public func nthProtein(idx: Int64) -> Result<Protein, Error> {
    var protein: protein? = nil
    var timestamp: pool_timestamp = 0
    let ok = pool_nth_protein(hose, idx, &protein, &timestamp)
    if ok == Retort.ok.rawValue {
      return .success(Protein(protein: protein!, timestamp: timestamp))
    } else {
      return .failure(Retort(ok))
    }
  }

  /// Retrieve the next available protein at or following the pool hose's current index,
  /// and advance the index to the position following.
  public func nextProtein() -> Result<Protein, Error> {
    var protein: protein? = nil
    var timestamp: pool_timestamp = 0
    var returnIdx: Int64 = 0
    let ok = pool_next(hose, &protein, &timestamp, &returnIdx)
    if ok == Retort.ok.rawValue {
      return .success(Protein(protein: protein!, timestamp: timestamp))
    } else {
      return .failure(Retort(ok))
    }
  }

  /// Retrieve the next available protein at or following the pool hose's current index,
  /// and advance the index to the position following. Waits if no protein is available.
  /// Specify the time to wait through the timeOut argument.
  public func awaitNextProtein(timeOut: ProteinWait = ProteinWait.forever) -> Result<
    Protein, Error
  > {
    let timeOutSecs =
      switch timeOut {
      case .forever: -1.0
      case .seconds(let secs): secs
      }
    var protein: protein? = nil
    var timestamp: pool_timestamp = 0
    var returnIdx: Int64 = 0
    let ok = pool_await_next(hose, timeOutSecs, &protein, &timestamp, &returnIdx)
    if ok == Retort.ok.rawValue {
      return .success(Protein(protein: protein!, timestamp: timestamp))
    } else {
      return .failure(Retort(ok))
    }
  }

  public func enableWakeup() -> Retort {
    let ok = pool_hose_enable_wakeup(hose)
    return Retort(ok)
  }

  public func wakeup() -> Retort {
    let ok = pool_hose_wake_up(hose)
    return Retort(ok)
  }

}
