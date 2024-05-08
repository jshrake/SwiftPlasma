//
//  PoolDiscovery.swift
//  PlasmaTest
//
//  Created by Justin Shrake on 5/7/24.
//

import Foundation

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
    print("Error browsing services: \(errorDict)")
  }

  public func netServiceBrowser(
    _ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool
  ) {
    if let index = services.firstIndex(of: service) {
      services.remove(at: index)
      let poolNames = pools.remove(at: index)
      delegate?.poolsVanished(pools: poolNames)
      print("Removed service: \(service.name)")
    }
  }

  // MARK: - NetServiceDelegate methods
  public func netServiceDidResolveAddress(_ sender: NetService) {
    guard let host = sender.hostName else {
      return print("could not resolve host")
    }
    let port = sender.port
    let addr = "tcp://\(host):\(port)/"
    switch Pool.list(address: addr) {
    case .failure(let error):
      return print("error listing pools at \(addr): \(error)")
    case .success(let poolNames):
      if let index = services.firstIndex(of: sender) {
        let resolvedNames = poolNames.map { "tcp://\(host):\(port)/\($0)" }
        pools.insert(resolvedNames, at: index)
        delegate?.poolsDiscovered(pools: resolvedNames)
      }
    }
  }

  public func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
    print("Failed to resolve \(sender.name): \(errorDict)")
  }
}
