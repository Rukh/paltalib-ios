//
//  BatchMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 15/06/2022.
//

import Foundation
import PaltaLibAnalytics

struct BatchMock: Batch {
    let shouldFailSerialize: Bool
    let data = Data((0...20).map { _ in UInt8.random(in: 0...255) })
    
    init(shouldFailSerialize: Bool = false) {
        self.shouldFailSerialize = shouldFailSerialize
    }
    
    init(common: BatchCommon, context: BatchContext, events: [BatchEvent]) {
        self.init()
    }
    
    init(data: Data) throws {
        self.init()
    }
    
    func serialize() throws -> Data {
        if shouldFailSerialize {
            throw NSError(domain: "", code: 0)
        } else {
            return data
        }
    }
}
