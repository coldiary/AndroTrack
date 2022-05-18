//
//  AppLogger.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-21.
//

import Foundation
import os

class AppLogger {
    
    private init() {}
    
    static private let logger = Logger()
    
    static func formatted(context: String?, _ message: String) -> String {
        "\(context != nil ? "[\(context!)]" : "") \(message)"
    }
    
    static func debug(context: String?, _ message: String) {
        logger.debug("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func info(context: String?, _ message: String) {
        logger.info("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func trace(context: String?, _ message: String) {
        logger.trace("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func log(context: String?, _ message: String) {
        logger.log("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func notice(context: String?, _ message: String) {
        logger.notice("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func warning(context: String?, _ message: String) {
        logger.warning("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func error(context: String?, _ message: String) {
        logger.error("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func fault(context: String?, _ message: String) {
        logger.fault("\(formatted(context: context, message), privacy: .public)")
    }
    
    static func critical(context: String?, _ message: String) {
        logger.critical("\(formatted(context: context, message), privacy: .public)")
    }
}
