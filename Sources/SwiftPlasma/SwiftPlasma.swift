// The Swift Programming Language
// https://docs.swift.org/swift-book
// The Swift Programming Language
// https://docs.swift.org/swift-book

import Plasma

public func test() {
    let sb = Plasma.slabu_new()
    Plasma.slabu_list_add_c(sb, "yo")
    let descrips = Plasma.slaw_list(sb)!
    Plasma.slabu_free(sb)
    let ingests = Plasma.slaw_map_empty()!
    let p = Plasma.protein_from(descrips, ingests)!
    var hose: Plasma.pool_hose? = nil
    let ok = Plasma.pool_participate("tcp://localhost/hello", &hose, nil)
    assert(ok == 0)
    if let hose = hose {
        let ok = Plasma.pool_deposit(hose, p, nil)
        assert(ok == 0)
    }
}
