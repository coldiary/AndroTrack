//
//  HealthKit.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-15.
//

import Foundation
import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    
    private let store = HKHealthStore()
    
    private let contraceptiveType = HKObjectType.categoryType(forIdentifier: .contraceptive)!
    private lazy var healthKitTypesToWrite: Set<HKSampleType> = { [contraceptiveType] }()
    private lazy var healthKitTypesToRead: Set<HKObjectType> = { [contraceptiveType] }()
    
    public var healthKitAuthorizationStatus: HKAuthorizationStatus { store.authorizationStatus(for: contraceptiveType) }
    
    public func removeRecord(at start: Date, completion: @escaping (HealthKitServiceError?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(HealthKitServiceError.HealthDataUnavailable)
            return
        }
        
        requestAccess { sucess, error in
            guard error == nil else {
                completion(HealthKitServiceError.AccessDenied)
                return
            }
            
            // Try to found record to remove
            let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
            
            let query = HKSampleQuery(sampleType: self.contraceptiveType, predicate: predicate, limit: 1, sortDescriptors: nil) {
                query, results, error in
                
                guard error == nil else {
                    completion(HealthKitServiceError.Failure(error!))
                    return
                }
                
                guard let samples = results as? [HKCategorySample] else {
                    completion(HealthKitServiceError.Failure(error!))
                    return
                }
               
                if (samples.count > 0) {
                    HKHealthStore().delete(samples[0]) { sucess, error in
                        if let error = error {
                            completion(HealthKitServiceError.Failure(error))
                            return
                        }
                        completion(nil)
                    }
                } else {
                    completion(HealthKitServiceError.RecordNotFound(start))
                }
            }
            
            HKHealthStore().execute(query)
        }
    }
    
    public func storeRecord(record: Record, completion: @escaping (HealthKitServiceError?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(HealthKitServiceError.HealthDataUnavailable)
            return
        }
        
        guard let start = record.start else {
            completion(HealthKitServiceError.InvalidRecord(property: "start"))
            return
        }
        
        requestAccess { sucess, error in
            guard error == nil else {
                completion(HealthKitServiceError.AccessDenied)
                return
            }

            let proceedStoringRecord = { (record: Record, completion: @escaping (HealthKitServiceError?) -> ()) in
                let contraceptiveSample = HKCategorySample(
                    type: self.contraceptiveType,
                    value: HKCategoryValueContraceptive.unspecified.rawValue,
                    start: start, end: record.end ?? start,
                    metadata: ["name": "AndroSwitch"]
                )

                self.store.save(contraceptiveSample) { (success, error) in
                    if let error = error {
                        completion(HealthKitServiceError.Failure(error))
                    } else {
                        completion(nil)
                    }
                }
            }
            
            // Try to found incomplete record to replace
            let predicate = HKQuery.predicateForSamples(withStart: record.start, end: Date())
            
            let query = HKSampleQuery(sampleType: self.contraceptiveType, predicate: predicate, limit: 1, sortDescriptors: nil) {
                query, results, error in
                
                guard error == nil else {
                    completion(HealthKitServiceError.Failure(error!))
                    return
                }
                
                guard let samples = results as? [HKCategorySample] else {
                    completion(HealthKitServiceError.Failure(error!))
                    return
                }
               
                if (samples.count > 0) {
                    HKHealthStore().delete(samples[0]) { sucess, error in
                        if let error = error {
                            completion(HealthKitServiceError.Failure(error))
                            return
                        }
                        
                        proceedStoringRecord(record, completion)
                    }
                } else {
                    proceedStoringRecord(record, completion)
                }
            }
            
            HKHealthStore().execute(query)
        }
    }
    
    public func fetchRecords(completion: @escaping ([Record]?, HealthKitServiceError?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil, HealthKitServiceError.HealthDataUnavailable)
            return
        }
        
        requestAccess { sucess, error in
            guard error == nil else {
                completion(nil, HealthKitServiceError.AccessDenied)
                return
            }
            
            let query = HKSampleQuery(sampleType: self.contraceptiveType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
                query, results, error in
                
                guard error == nil else {
                    completion(nil, HealthKitServiceError.Failure(error!))
                    return
                }
                
                guard let samples = results as? [HKCategorySample] else {
                    completion(nil, HealthKitServiceError.Failure(error!))
                    return
                }
               
                let records = samples.map { Record(start: $0.startDate, end: $0.startDate == $0.endDate ? nil : $0.endDate) }
                
                DispatchQueue.main.async {
                    completion(records, nil)
                }
            }
            
            HKHealthStore().execute(query)
            
        }
        
        
    }
    
    public func registerForSync(withCallback: @escaping  (HealthKitServiceError?) -> (), completion: @escaping (HealthKitServiceError?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(HealthKitServiceError.HealthDataUnavailable)
            return
        }
        
        self.requestAccess { sucess, error in
            guard error == nil else {
                completion(HealthKitServiceError.AccessDenied)
                return
            }
            
            let sampleObserver = HKObserverQuery(
                sampleType: self.contraceptiveType,
                predicate: nil
            ) { (query, completionHandler, error: Error?) in
                if let error = error {
                    withCallback(HealthKitServiceError.Failure(error))
                    return
                }
                completionHandler()
                DispatchQueue.main.async {
                    withCallback(nil)
                }
            }

            self.store.execute(sampleObserver)
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    public func requestAccess(completion: @escaping (Bool, HealthKitServiceError?) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitServiceError.HealthDataUnavailable)
            return
        }
        
        store.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success: Bool, error: Error?) in
            if let error = error {
                completion(false, HealthKitServiceError.Failure(error))
            } else {
                completion(success, nil)
            }
        }
    }
    
    public func checkAuthorizationRequestStatus(completion: @escaping (HKAuthorizationRequestStatus?, HealthKitServiceError?) -> ()) {
        store.getRequestStatusForAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { status, error in
            if let error = error {
                completion(nil, HealthKitServiceError.Failure(error))
            } else {
                completion(status, nil)
            }
        }
    }
}

enum HealthKitServiceError: Error {
    case HealthDataUnavailable
    case CategoryTypeNotFound
    case InvalidRecord(property: String)
    case RecordNotFound(Date)
    case AccessDenied
    case Failure(Error)
}

extension HealthKitServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .AccessDenied:
                return NSLocalizedString("HealthKit: Access denied to HealthKit data", comment: "")
            case .CategoryTypeNotFound:
                return NSLocalizedString("HealthKit: CategoryType not found", comment: "")
            case .Failure(let err):
                return NSLocalizedString("HealthKit: Failure \(err)", comment: "")
            case .HealthDataUnavailable:
                return NSLocalizedString("HealthKit: Access denied to HealthKit data", comment: "")
            case .InvalidRecord(let property):
                return NSLocalizedString("HealthKit: Invalid record can't be stored. Property \(property) is missing", comment: "")
        case .RecordNotFound(let start):
            return NSLocalizedString("HealthKit: Record with start \(start) not found", comment: "")
        }
    }
}
