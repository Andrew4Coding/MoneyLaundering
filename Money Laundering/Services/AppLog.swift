//
//  AppLog.swift
//  Money Laundering
//

import OSLog

/// Shared `os.Logger` instances. View them in Console.app or `log stream --predicate
/// 'subsystem == "com.andrew4coding.moneylaundering.Money-Laundering"'`.
enum AppLog {
    private static let subsystem = "com.andrew4coding.moneylaundering.Money-Laundering"

    static let billScan = Logger(subsystem: subsystem, category: "BillScan")
}
