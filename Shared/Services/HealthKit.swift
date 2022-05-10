//
//  HealthKit.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-15.
//

import Foundation
import HealthKit
import Combine

class HealthKitService {
    static let shared = HealthKitService()
    
    private let store = HKHealthStore()
    
    private let contraceptiveType = HKObjectType.categoryType(forIdentifier: .contraceptive)!
    private lazy var healthKitTypesToWrite: Set<HKSampleType> = { [contraceptiveType] }()
    private lazy var healthKitTypesToRead: Set<HKObjectType> = { [contraceptiveType] }()
    
    private let syncPub = PassthroughSubject<HKObserverQueryCompletionHandler, HealthKitServiceError>()
    
    public var healthKitAuthorizationStatus: HKAuthorizationStatus { store.authorizationStatus(for: contraceptiveType) }
   
    public func editRecord(id: UUID, _ newValues: Record, completion: @escaping (Result<UUID, HealthKitServiceError>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return completion(.failure(HealthKitServiceError.HealthDataUnavailable))
        }
        
        requestAccess { result in
            guard case .success(_) = result else {
                return completion(.failure(HealthKitServiceError.AccessDenied))
            }
            
            // Try to found record to replace
            let predicate = HKQuery.predicateForObject(with: id)
            
            let query = HKSampleQuery(sampleType: self.contraceptiveType, predicate: predicate, limit: 1, sortDescriptors: nil) {
                query, results, error in
                
                guard error == nil else {
                    return completion(.failure(HealthKitServiceError.Failure(error!)))
                }
                
                guard let samples = results as? [HKCategorySample] else {
                    return completion(.failure(HealthKitServiceError.Failure(error!)))
                }
               
                if (samples.count > 0) {
                    self.store.delete(samples[0]) { sucess, error in
                        if let error = error {
                            return completion(.failure(HealthKitServiceError.Failure(error)))
                        }
                        
                        let contraceptiveSample = HKCategorySample(
                            type: self.contraceptiveType,
                            value: HKCategoryValueContraceptive.unspecified.rawValue,
                            start: newValues.start,
                            end: newValues.end,
                            metadata: [
                                "name": "AndroSwitch",
                                "goal": newValues.goal?.description ?? "",
                            ]
                        )

                        self.store.save(contraceptiveSample) { (success, error) in
                            if let error = error {
                                completion(.failure(HealthKitServiceError.Failure(error)))
                            } else {
                                completion(.success(contraceptiveSample.uuid))
                            }
                        }
                    }
                } else {
                    completion(.failure(HealthKitServiceError.RecordNotFound(id)))
                }
            }
            
            self.store.execute(query)
        }
    }
    
    public func removeRecord(id: UUID, completion: @escaping (HealthKitServiceError?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(HealthKitServiceError.HealthDataUnavailable)
            return
        }
        
        requestAccess { result in
            guard case .success(_) = result else {
                completion(HealthKitServiceError.AccessDenied)
                return
            }
            
            // Try to found record to remove
            let predicate = HKQuery.predicateForObject(with: id)
            
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
                    self.store.delete(samples[0]) { sucess, error in
                        if let error = error {
                            completion(HealthKitServiceError.Failure(error))
                            return
                        }
                        completion(nil)
                    }
                } else {
                    completion(HealthKitServiceError.RecordNotFound(id))
                }
            }
            
            self.store.execute(query)
        }
    }
    
    public func addRecord(record: Record, completion: @escaping (Result<UUID, HealthKitServiceError>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return completion(.failure(HealthKitServiceError.HealthDataUnavailable))
        }
        
        requestAccess { result in
            guard case .success(_) = result else {
                return completion(.failure(HealthKitServiceError.AccessDenied))
            }

            let contraceptiveSample = HKCategorySample(
                type: self.contraceptiveType,
                value: HKCategoryValueContraceptive.unspecified.rawValue,
                start: record.start,
                end: record.end,
                metadata: [
                    "name": "AndroSwitch",
                    "goal": record.goal?.description ?? "",
                ]
            )

            self.store.save(contraceptiveSample) { (success, error) in
                if let error = error {
                    completion(.failure(HealthKitServiceError.Failure(error)))
                } else {
                    completion(.success(contraceptiveSample.uuid))
                }
            }
        }
    }
    
    public func fetchRecords(from: Date? = nil, to: Date? = nil, completion: @escaping (Result<[Record], HealthKitServiceError>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return completion(.failure(HealthKitServiceError.HealthDataUnavailable))
        }
        
        requestAccess { result in
            guard case .success(_) = result else {
                return completion(.failure(HealthKitServiceError.AccessDenied))
            }
            
            var predicate: NSPredicate? = nil;
            if let from = from {
                predicate = HKQuery.predicateForSamples(withStart: from, end: to)
            }
            
            let query = HKSampleQuery(sampleType: self.contraceptiveType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
                query, results, error in
                
                guard error == nil else {
                    return completion(.failure(HealthKitServiceError.Failure(error!)))
                }
                
                guard let samples = results as? [HKCategorySample] else {
                    return completion(.failure(HealthKitServiceError.Failure(error!)))
                }
               
                let records = samples.map { sample -> Record in
                    let goal = Int(sample.metadata?["goal"] as! String? ?? "") ?? 15
                    let hasUdeterminedDuration = sample.hasUndeterminedDuration || sample.startDate == sample.endDate
                    return Record(
                        id: sample.uuid,
                        start: sample.startDate,
                        end: hasUdeterminedDuration ? Date.distantFuture : sample.endDate,
                        goal: hasUdeterminedDuration ? nil : goal
                    )
                }
                
                DispatchQueue.main.async {
                    completion(.success(records))
                }
            }
            
            self.store.execute(query)
            
        }
        
        
    }
    
    public func registerForSync() -> AnyPublisher<HKObserverQueryCompletionHandler, HealthKitServiceError> {
        guard HKHealthStore.isHealthDataAvailable() else {
            return Fail(error: HealthKitServiceError.HealthDataUnavailable)
                .eraseToAnyPublisher()
        }
        
        requestAccess { result in
            guard case .success(_) = result else {
                return self.syncPub.send(completion: .failure(HealthKitServiceError.AccessDenied))
            }
            
            let sampleObserver = HKObserverQuery(
                sampleType: self.contraceptiveType,
                predicate: nil
            ) { (query, completionHandler, error: Error?) in
                if let error = error {
                    return self.syncPub.send(completion: .failure(HealthKitServiceError.Failure(error)))
                }
                
                self.syncPub.send(completionHandler)
            }

            self.store.execute(sampleObserver)
        }
        
        return syncPub.eraseToAnyPublisher()
    }
    
    public func requestAccess(completion: @escaping (Result<Bool, HealthKitServiceError>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.failure(HealthKitServiceError.HealthDataUnavailable))
            return
        }
        
        store.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success: Bool, error: Error?) in
            if let error = error {
                completion(.failure(HealthKitServiceError.Failure(error)))
            } else {
                completion(.success(success))
            }
        }
    }
    
    public func checkAuthorizationRequestStatus(completion: @escaping (Result<HKAuthorizationRequestStatus, HealthKitServiceError>) -> Void) {
        store.getRequestStatusForAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { status, error in
            if let error = error {
                completion(.failure(HealthKitServiceError.Failure(error)))
            } else {
                completion(.success(status))
            }
        }
    }
}

enum HealthKitServiceError: Error {
    case HealthDataUnavailable
    case CategoryTypeNotFound
    case InvalidRecord(property: String)
    case RecordNotFound(UUID)
    case AccessDenied
    case NoData
    case Failure(Error)
}

extension HealthKitServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .HealthDataUnavailable:
            return NSLocalizedString("HealthKit: HealthKit data unavailable", comment: "")
        case .AccessDenied:
            return NSLocalizedString("HealthKit: Access denied to HealthKit data", comment: "")
        case .CategoryTypeNotFound:
            return NSLocalizedString("HealthKit: CategoryType not found", comment: "")
        case .Failure(let err):
            return NSLocalizedString("HealthKit: Failure \(err)", comment: "")
        case .InvalidRecord(let property):
            return NSLocalizedString("HealthKit: Invalid record can't be stored. Property \(property) is missing", comment: "")
        case .NoData:
            return NSLocalizedString("HealthKit: No HealthKit data", comment: "")
        case .RecordNotFound(let id):
            return NSLocalizedString("HealthKit: Record with UUID \(id) not found", comment: "")
        }
    }
}
