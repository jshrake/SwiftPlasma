// The Swift Programming Language
// https://docs.swift.org/swift-book

import Plasma

public struct Slaw {
    let slaw: slaw

    public init(_ slaw: slaw) {
        self.slaw = slaw
    }

    public init(_ x: Int16) {
        self.slaw = slaw_int16(x)
    }

    public init(_ x: [Int16]) {
        self.slaw = slaw_int16_array(x, Int64(x.count))
    }

    public init(_ x: Int32) {
        self.slaw = slaw_int32(x)
    }

    public init(_ x: [Int32]) {
        self.slaw = slaw_int32_array(x, Int64(x.count))
    }

    public init(_ x: Int64) {
        self.slaw = slaw_int64(x)
    }

    public init(_ x: [Int64]) {
        self.slaw = slaw_int64_array(x, Int64(x.count))
    }

    public init(_ x: Int) {
        switch MemoryLayout<Int>.size {
            case 4:
                self.init(Int32(x))
            default:
                self.init(Int64(x))
        }
    }


    public init(_ x: Float32) {
        self.slaw = slaw_float32(x)
    }

    public init(_ x: [Float32]) {
        self.slaw = slaw_float32_array(x, Int64(x.count))
    }

    public init(_ x: Float64) {
        self.slaw = slaw_float64(x)
    }

    public init(_ x: [Float64]) {
        self.slaw = slaw_float64_array(x, Int64(x.count))
    }

    public init(_ s: String) {
        self.slaw = slaw_string(s)
    }

    public init(_ list: [String]) {
        let sb = slabu_new()
        defer { slabu_free(sb) }
        for s in list {
            slabu_list_add_c(sb, s)
        }
        self.slaw = slaw_list(sb)!
    }

    public init(_ dict: Dictionary<String, Any>) {
        let sb = slabu_new()
        defer { slabu_free(sb) }
        for s in dict {
            slabu_map_put(sb, Slaw(s.key).slaw, Slaw(from: s.value).slaw)
        }
        self.slaw = slaw_map(sb)!
    }



    public init(from x: Any) {
        switch x {
        case let x as Int:
            self.init(x)
        case let x as Int16:
            self.init(x)
        case let x as [Int16]:
            self.init(x)
        case let x as Int32:
            self.init(x)
        case let x as [Int32]:
            self.init(x)
        case let x as Int64:
            self.init(x)
        case let x as [Int64]:
            self.init(x)
        case let x as Float32:
            self.init(x)
        case let x as [Float32]:
            self.init(x)
        case let x as Float64:
            self.init(x)
        case let x as [Float64]:
            self.init(x)
        case let x as String:
            self.init(x)
        case let x as [String]:
            self.init(x)
        default:
            fatalError("unsupported type")
        }
    }
}

public struct Protein {
    let descrips: Slaw
    let ingests: Slaw
    let bslaw: bslaw

    public init(descrips: Array<String>, ingests: Dictionary<String, Any>) {
        self.descrips = Slaw(descrips)
        self.ingests = Slaw(ingests)
        self.bslaw = protein_from(self.descrips.slaw, self.ingests.slaw)
    }
}

public struct PoolCreateOptions {
    let size: Int
}

public struct Pool {
    let hose: pool_hose

    public static func create(addr: String, options: PoolCreateOptions) -> Result<(), Error> {
        let ok = pool_create(addr, "mmap", Slaw(["size": options.size]).slaw)
        if ok == 0 {
            return .success(())
        } else {
            return .failure(Retort(ok))
        }
    }

    public static func participate(addr: String) -> Result<Pool, Error> {
        var hose: pool_hose? = nil
        let ok = pool_participate(addr, &hose, nil)
        if ok == 0 {
            return .success(Pool(hose: hose!))
        } else {
            return .failure(Retort(ok))
        }
    }

    public func deposit(_ p: Protein) -> Retort {
        let ok = pool_deposit(hose, p.bslaw, nil)
        return Retort(ok)
    }
}

public enum Retort: Int, Error {
    case Ok = 0
    case NotOk

    public init(_ v: ob_retort) {
        switch v {
        case 0:
            self = .Ok
        default:
            self = .NotOk
        }
    }
}
