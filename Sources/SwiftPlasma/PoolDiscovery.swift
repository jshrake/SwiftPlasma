//
//  PoolDiscovery.swift
//  PlasmaTest
//
//  Created by Justin Shrake on 5/7/24.
//

import Foundation
import Logging

let log = Logger(label: "com.jshrake.SwiftPlasma.PoolDiscovery")

public protocol PoolDiscoveryDelegate {
  func poolsDiscovered(pools: [String])
  func poolsVanished(pools: [String])
}

public class PoolDiscovery: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
  var serviceBrowser = NetServiceBrowser()
  var services = [NetService]()
  public var pools = [[String]]()
  public var delegate: PoolDiscoveryDelegate?

  public override init() {
    super.init()
    serviceBrowser.delegate = self
  }

  public func monitorLocal() {
    monitor(domain: "local.")
  }

  public func monitor(domain: String) {
    serviceBrowser.searchForServices(ofType: "_pool-server._tcp.", inDomain: domain)
  }

  public func check() {
    for service in services {
      service.resolve(withTimeout: 10)
    }
  }

  // MARK: - NetServiceBrowserDelegate methods
  public func netServiceBrowser(
    _ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool
  ) {
    services.append(service)
    service.delegate = self
    service.resolve(withTimeout: 10)
  }

  public func netServiceBrowser(
    _ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]
  ) {
    log.error("Unexpected error browsing services: \(errorDict)")
  }

  public func netServiceBrowser(
    _ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool
  ) {
    if let index = services.firstIndex(of: service) {
      services.remove(at: index)
      let poolNames = pools.remove(at: index)
      delegate?.poolsVanished(pools: poolNames)
      log.info("Removed service: \(service.name)")
      log.info("Pools vanished: \(poolNames)")
    }
  }

  // MARK: - NetServiceDelegate methods
  public func netServiceDidResolveAddress(_ sender: NetService) {
    log.info("Service resolved: \(sender.name)")
    guard let host = sender.hostName else {
      return log.error("Unexpevted error resolving host for \(sender.name)")
    }
    let port = sender.port
    let addr = "tcp://\(host):\(port)/"
    switch Pool.list(address: addr) {
    case .failure(let error):
      return log.error("Unexpevted error listing pools at \(addr): \(error)")
    case .success(let poolNames):
      if let index = services.firstIndex(of: sender) {
        let resolvedNames = poolNames.map { "tcp://\(host):\(port)/\($0)" }
        pools.insert(resolvedNames, at: index)
        delegate?.poolsDiscovered(pools: resolvedNames)
        log.info("Pools disxocered: \(resolvedNames)")
      }
    }
  }

  public func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
    log.error("Failed to resolve \(sender.name): \(errorDict)")
  }
}
