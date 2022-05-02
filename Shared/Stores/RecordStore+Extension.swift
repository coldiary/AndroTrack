//
//  RecordStore+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-12-29.
//

import Foundation

// Compute stats
extension RecordStore {
    public func loadAllHealthData(completion: ((Error?) -> ())? = nil) {
        HealthKitService.shared.fetchRecords { records, error in
            if let error = error {
                AppLogger.error(context: "RecordStore", "Failure: \(error.errorDescription!)")
                completion?(error)
                return
            }
            
            self.all = records
            completion?(nil)
        }
    }
    
    public func computeStats(completion: ((Error?) -> ())? = nil) {
        if stats == nil {
            loadAllHealthData { error in
                if let error = error {
                    AppLogger.error(context: "RecordStore", "Failure: computeStats - \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion?(error)
                    }
                    return
                }
                
                self.stats = Stats(store: self)
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }
    }
}


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
