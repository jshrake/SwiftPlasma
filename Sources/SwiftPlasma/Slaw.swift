import Plasma

/// Owns a plasma c slaw, and frees it when deinitialized.
public class Slaw: BSlaw {
  deinit {
    slaw_free(self.slaw)
  }

  convenience init(dup other: BSlaw) {
    self.init(slaw_dup(other.slaw))
  }
}

/// References a plasma c slaw, and doesn't free it when deinitialized.
public class BSlaw {
  public let slaw: slaw

  public init() {
    self.slaw = slaw_nil()!
  }

  public init(_ slaw: slaw) {
    self.slaw = slaw
  }

  public init(_ other: BSlaw) {
    self.slaw = other.slaw
  }

  /// Construct a Slaw from Int16.
  public init(_ x: Bool) {
    self.slaw = slaw_boolean(x)
  }

  /// Construct a Slaw from Int16.
  public init(_ x: Int16) {
    self.slaw = slaw_int16(x)
  }

  /// Construct a Slaw from a [Int16]
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

  public init(_ x: UInt16) {
    self.slaw = slaw_unt16(x)
  }

  public init(_ x: UInt32) {
    self.slaw = slaw_unt32(x)
  }

  public init(_ x: UInt64) {
    self.slaw = slaw_unt64(x)
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

  public init(_ list: [Any]) {
    let sb = slabu_new()
    defer { slabu_free(sb) }
    for a in list {
      slabu_list_add_z(sb, BSlaw(a).slaw)
    }
    self.slaw = slaw_list(sb)!
  }

  public init(_ dict: [String: Any]) {
    let sb = slabu_new()
    defer { slabu_free(sb) }
    for s in dict {
      let k = s.key
      let v = BSlaw(s.value)
      slabu_list_add_z(sb, slaw_cons_cl(k, v.slaw))
    }
    self.slaw = slaw_map(sb)!
  }

  public convenience init(_ x: Int) {
    switch MemoryLayout<Int>.size {
    case 4:
      self.init(Int32(x))
    default:
      self.init(Int64(x))
    }
  }

  public convenience init(_ x: UInt) {
    switch MemoryLayout<UInt>.size {
    case 4:
      self.init(UInt32(x))
    default:
      self.init(UInt64(x))
    }
  }

  public convenience init(_ x: [Int]) {
    switch MemoryLayout<Int>.size {
    case 4:
      self.init(x.map { Int32($0) })
    default:
      self.init(x.map { Int64($0) })
    }
  }

  public convenience init(_ x: Any?) {
    if x == nil {
      self.init(slaw_nil()!)
    } else {
      self.init(x!)
    }
  }

  public convenience init(_ x: Any) {
    switch x {
    case let x as Int:
      self.init(x)
    case let x as UInt:
      self.init(x)
    case let x as Bool:
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
    case let x as [Int]:
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
    case let x as [String: Any]:
      self.init(x)
    case let x as [Any]:
      self.init(x)
    default:
      let m = Mirror(reflecting: x)
      fatalError("Cannot create slaw from Any with type \"\(m.subjectType)\"")
    }
  }

  /// Retruns a YAML string representation of the slaw,
  /// assuming that the underlying plasma library was built with YAML_SUPPORT=ON
  public func toYamlString() -> Result<String, Retort> {
    var slawString: slaw? = nil
    let options = Slaw([
      "tag_numbers": true,
      "directives": true,
      "ordered_maps": true,
    ])
    let tort = Retort(slaw_to_string_options(self.slaw, &slawString, options.slaw))
    if tort.isOk && slawString != nil {
      let b = slaw_string_emit(slawString)!
      let s = String(cString: b)
      return .success(s)
    } else {
      return .failure(tort)
    }
  }
}

extension BSlaw {
  public func emit<T>() -> T? {
    switch T.self {
    case is Bool.Type:
      return slaw_boolean_emit(self.slaw).map { Bool($0.pointee) } as? T
    case is String.Type:
      return slaw_string_emit(self.slaw).map { String(cString: $0) } as? T
    case is UInt16.Type:
      return slaw_unt16_emit(self.slaw).map { UInt16($0.pointee) } as? T
    case is UInt32.Type:
      return slaw_unt32_emit(self.slaw).map { UInt32($0.pointee) } as? T
    case is UInt64.Type:
      return slaw_unt64_emit(self.slaw).map { UInt64($0.pointee) } as? T
    case is UInt.Type:
      switch MemoryLayout<UInt>.size {
      case 4:
        return slaw_unt32_emit(self.slaw).map { UInt($0.pointee) } as? T
      default:
        return slaw_unt64_emit(self.slaw).map { UInt($0.pointee) } as? T
      }
    case is Int16.Type:
      return slaw_int16_emit(self.slaw).map { Int16($0.pointee) } as? T
    case is Int32.Type:
      return slaw_int32_emit(self.slaw).map { Int32($0.pointee) } as? T
    case is Int64.Type:
      return slaw_int64_emit(self.slaw).map { Int64($0.pointee) } as? T
    case is Int.Type:
      switch MemoryLayout<Int>.size {
      case 4:
        return slaw_int32_emit(self.slaw).map { Int($0.pointee) } as? T
      default:
        return slaw_int64_emit(self.slaw).map { Int($0.pointee) } as? T
      }
    case is Float.Type:
      return slaw_float32_emit(self.slaw).map { Float($0.pointee) } as? T
    case is Double.Type:
      return slaw_float64_emit(self.slaw).map { Double($0.pointee) } as? T
    case is Float32.Type:
      return slaw_float32_emit(self.slaw).map { Float32($0.pointee) } as? T
    case is Float64.Type:
      return slaw_float64_emit(self.slaw).map { Float64($0.pointee) } as? T
    case is [UInt].Type:
      let a: [UInt] = self.emitNumericArray()!
      return a as? T
    case is [UInt16].Type:
      let a: [UInt16] = self.emitNumericArray()!
      return a as? T
    case is [UInt32].Type:
      let a: [UInt32] = self.emitNumericArray()!
      return a as? T
    case is [UInt64].Type:
      let a: [UInt64] = self.emitNumericArray()!
      return a as? T
    case is [Int].Type:
      let a: [Int] = self.emitNumericArray()!
      return a as? T
    case is [Int16].Type:
      let a: [Int16] = self.emitNumericArray()!
      return a as? T
    case is [Int32].Type:
      let a: [Int32] = self.emitNumericArray()!
      return a as? T
    case is [Int64].Type:
      let a: [Int64] = self.emitNumericArray()!
      return a as? T
    case is [Float].Type:
      let a: [Float] = self.emitNumericArray()!
      return a as? T
    case is [Double].Type:
      let a: [Double] = self.emitNumericArray()!
      return a as? T
    case is [Float32].Type:
      let a: [Float32] = self.emitNumericArray()!
      return a as? T
    case is [Float64].Type:
      let a: [Float64] = self.emitNumericArray()!
      return a as? T
    case is [String].Type:
      let a: [String] = self.emitList()!
      return a as? T
    case is [Bool].Type:
      let a: [Bool] = self.emitList()!
      return a as? T
    case is [Any].Type:
      let a: [Any] = self.emitList()!
      return a as? T
    case is [String: Any].Type:
      let a: [String: Any] = self.emitMap()!
      return a as? T
    default:
      if let v = self.emitAny() {
        return v as? T
      } else {
        return nil
      }
    }
  }

  func emitList<T>() -> [T]? {
    let count = slaw_list_count(self.slaw)
    var array = [T]()
    for i in 0..<count {
      let vs = slaw_list_emit_nth(self.slaw, i)!
      let v: T = BSlaw(vs).emit()!
      array.append(v)
    }
    return array
  }

  func emitMap<T>() -> [String: T]? {
    let count = slaw_list_count(self.slaw)
    var map = [String: T]()
    for i in 0..<count {
      let ns = slaw_list_emit_nth(self.slaw, i)!
      let ks = slaw_cons_emit_car(ns)!
      let vs = slaw_cons_emit_cdr(ns)!
      let k: String = BSlaw(ks).emit()!
      let v: T? = BSlaw(vs).emit()
      map[k] = v
    }
    return map
  }

  func emitNumericArray<T>() -> [T]? {
    let count = slaw_numeric_array_count(self.slaw)
    let ptr: UnsafeRawPointer = slaw_numeric_array_emit(self.slaw)!
    let typedPtr = ptr.assumingMemoryBound(to: T.self)
    let buffer = UnsafeBufferPointer(start: typedPtr, count: Int(count))
    let array = Array(buffer)
    return array
  }

  public func emitAny() -> Any? {
    if self.isString() {
      let v: String = self.emit()!
      return v
    } else if self.isBool() {
      let v: Bool = self.emit()!
      return v
    } else if self.isInt16() {
      let v: Int16 = self.emit()!
      return v
    } else if self.isInt32() {
      let v: Int32 = self.emit()!
      return v
    } else if self.isInt64() {
      let v: Int64 = self.emit()!
      return v
    } else if self.isFloat32() {
      let v: Float32 = self.emit()!
      return v
    } else if self.isFloat64() {
      let v: Float64 = self.emit()!
      return v
    } else if self.isList() {
      let v: [Any] = self.emitList()!
      return v
    } else if self.isMap() {
      let v: [String: Any] = self.emitMap()!
      return v
    } else if slaw_is_float32_array(self.slaw) {
      let v: [Float32] = self.emitNumericArray()!
      return v
    } else if slaw_is_float64_array(self.slaw) {
      let v: [Float64] = self.emitNumericArray()!
      return v
    } else if slaw_is_int16_array(self.slaw) {
      let v: [Int16] = self.emitNumericArray()!
      return v
    } else if slaw_is_int32_array(self.slaw) {
      let v: [Int32] = self.emitNumericArray()!
      return v
    } else if slaw_is_int64_array(self.slaw) {
      let v: [Int64] = self.emitNumericArray()!
      return v
    } else if slaw_is_unt16_array(self.slaw) {
      let v: [UInt16] = self.emitNumericArray()!
      return v
    } else if slaw_is_unt32_array(self.slaw) {
      let v: [UInt32] = self.emitNumericArray()!
      return v
    } else if slaw_is_unt64_array(self.slaw) {
      let v: [UInt64] = self.emitNumericArray()!
      return v
    } else if slaw_is_unt8_array(self.slaw) {
      let v: [UInt8] = self.emitNumericArray()!
      return v
    } else if slaw_is_int8_array(self.slaw) {
      let v: [Int8] = self.emitNumericArray()!
      return v
    } else if slaw_is_nil(self.slaw) {
      return nil
    } else {
      return nil
    }
  }

  public func isProtein() -> Bool {
    slaw_is_protein(self.slaw)
  }

  public func isNil() -> Bool {
    slaw_is_nil(self.slaw)
  }

  public func isList() -> Bool {
    slaw_is_list(self.slaw)
  }

  public func isMap() -> Bool {
    slaw_is_map(self.slaw)
  }

  public func isString() -> Bool {
    slaw_is_string(self.slaw)
  }

  public func isNumeric() -> Bool {
    slaw_is_numeric(self.slaw)
  }

  public func isNumericArray() -> Bool {
    slaw_is_numeric_array(self.slaw)
  }

  public func isBool() -> Bool {
    slaw_is_boolean(self.slaw)
  }

  public func isInt16() -> Bool {
    slaw_is_int16(self.slaw)
  }

  public func isInt32() -> Bool {
    slaw_is_int32(self.slaw)
  }

  public func isInt64() -> Bool {
    slaw_is_int64(self.slaw)
  }

  public func isFloat32() -> Bool {
    slaw_is_float32(self.slaw)
  }

  public func isFloat64() -> Bool {
    slaw_is_float64(self.slaw)
  }
}

extension BSlaw: Hashable {
  public static func == (lhs: BSlaw, rhs: BSlaw) -> Bool {
    slawx_equal(lhs.slaw, rhs.slaw)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(slaw_hash(self.slaw))
  }

}

extension BSlaw: CustomStringConvertible {
  public var description: String {
    switch self.toYamlString() {
    case .success(let s):
      return s
    case .failure(let r):
      return "Error: \(r)"
    }
  }
}
