public enum Retort: Int64, Error {
  // Common Success Codes
  case ok = 0
  case stop = 300
  case nothingToDo = 301
  case yes = 302
  case no = 303
  case bounce = 304

  // Common Error Codes
  case noMemory = -201
  case badIndex = -202
  case argumentWasNull = -203
  case notFound = -204
  case invalidArgument = -205
  case unknownError = -220
  case inadequateClass = -221
  case alreadyPresent = -222
  case empty = -223
  case invalidOperation = -224
  case disconnected = -260
  case versionMismatch = -261

  // Slaw-related errors
  case corruptProtein = -210000
  case corruptSlaw = -210001
  case fabricatorBadness = -210002
  case notNumeric = -210003
  case rangeError = -210004
  case unidentifiedSlaw = -210005
  case wrongLength = -210006
  case slawNotFound = -210007

  // I/O-related errors
  case aliasNotSupported = -220000
  case badTag = -220001
  case endOfFile = -220002
  case parsingBadness = -220003
  case wrongFormat = -220004
  case wrongVersion = -220005
  case yamlError = -220006
  case noYaml = -220007

  // Pool-specific errors
  case noPoolsDir = -200400
  case fileOperationFailed = -200500
  case nullHose = -200505
  case semaphoresBad = -200510
  case mmapFailed = -200520
  case inappropriateFileSystem = -200525
  case poolInUse = -200530
  case unknownPoolType = -200540
  case configProblem = -200545
  case unexpectedPoolVersion = -200547
  case corruptPool = -200548
  case badPoolName = -200550
  case impossibleRename = -200551
  case fifoProblem = -200555
  case invalidPoolSize = -200560
  case noSuchPool = -200570
  case poolAlreadyExists = -200575
  case illegalNesting = -200576
  case protocolError = -200580
  case noSuchProtein = -200635
  case awaitTimeout = -200640
  case awaitWoken = -200650
  case wakeupNotEnabled = -200660
  case proteinTooLarge = -200700
  case poolFrozen = -200710
  case poolFull = -200720
  case notAProtein = -200800
  case notAProteinOrMap = -200810
  case configWriteError = -200900
  case configReadError = -200910
  case sendError = -201000
  case receiveError = -201010
  case unexpectedClose = -201015
  case socketError = -201020
  case serverBusy = -201030
  case serverUnreachable = -201040
  case alreadyGangMember = -201050
  case notAGangMember = -201055
  case emptyGang = -201060
  case nullGang = -201070
  case unsupportedOperation = -201100
  case invalidatedByFork = -201110
  case noTLS = -201500
  case tlsRequired = -201505
  case tlsError = -201510
  case notAGreenhouseServer = -201600
  case unknown

  init(_ tort: Int64) {
    self = Retort(rawValue: tort) ?? .unknown
  }

  public var isOk: Bool {
    self == .ok
  }

  public var isError: Bool {
    self.rawValue < 0
  }
}

public func tort(with operation: () -> Int64) -> Result<(), Retort> {
  let retort = Retort(operation())
  if retort.isOk {
    return .success(())
  } else {
    return .failure(retort)
  }
}

public func tortWithReturn<T>(with operation: () -> (Int64, T)) -> Result<T, Retort> {
  let (tort, v) = operation()
  let retort = Retort(tort)
  if retort.isOk {
    return .success(v)
  } else {
    return .failure(retort)
  }
}
