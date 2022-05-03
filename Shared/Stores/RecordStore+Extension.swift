//
//  RecordStore+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-29.
//

import Foundation

// Export as CSVFile
extension RecordStore {
    public func exportAsCSVFile() -> CSVFile {
        let headers: [String] = ["start,end"]
        let data: [String] = records.map { record in
            "\(record.start.toISOString()), \(record.end != Date.distantFuture ? "\(record.end.toISOString())" : "")"
        }
        let content = (headers + data).joined(separator: "\n")
        return CSVFile(initialText: content)
    }
}
