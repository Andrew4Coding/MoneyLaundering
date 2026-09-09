//
//  AppLog.swift
//  Swiftlet
//

import OSLog

/// Shared `os.Logger` instances. View them in Console.app or `log stream --predicate
/// 'subsystem == "com.andrew4coding.swiftlet.Swiftlet"'`.
enum AppLog {
    private static let subsystem = "com.andrew4coding.swiftlet.Swiftlet"

    static let billScan = Logger(subsystem: subsystem, category: "BillScan")
}
