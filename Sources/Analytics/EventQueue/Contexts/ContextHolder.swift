//
//  ContextHolder.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

//protocol ContextHolder {
//    func context(with id: UUID) -> BatchContext
//    func stripContexts(excluding contextIds: Set<UUID>)
//}
//
//final class ContextHolderImpl: ContextModifier {
//    var context: BatchContext {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        if let context = _context {
//            return context
//        }
//        
//        let context = loadContext()
//        _context = context
//        return context
//    }
//    
//    private var _context: BatchContext?
//    
//    private var
//    
//    private let lock = NSRecursiveLock()
//    private let stack: Stack
//    
//    init(stack: Stack) {
//        self.stack = stack
//    }
//    
//    func editContext(_ editor: (inout BatchContext) -> Void) {
//        lock.lock()
//        var context = _context ?? loadContext()
//        editor(&context)
//        _context = context
//        lock.unlock()
//    }
//    
//    private func loadContext() -> BatchContext {
//        stack.context.init()
//    }
//}
