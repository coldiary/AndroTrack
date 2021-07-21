//
//  WatchConnectivity.swift
//  AndroTrack
//
//  Created by Benoit Sida on 2021-07-19.
//

import Foundation
import WatchConnectivity
import Combine

#if os(watchOS)
import WatchKit
#endif


class WatchConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivity()
    
    public let session: WCSession = .default
    public let publisher = PassthroughSubject<[String:Any], Never>()
    
    @Published var isReachable = false
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activate()
        } else {
            AppLogger.warning(context: "WatchConnectivity", "WatchConnectivity not supported")
        }
    }
    
    // MARK: - Phone
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if session.isReachable {
            sync()
        }
    }
    
    func sync() {
        if (session.isReachable) {
            do {
                try session.updateApplicationContext(SettingsStore.shared.appContext)
            } catch {
                AppLogger.error(context: "WatchConnectivity", "Sync error: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            AppLogger.error(context: "WatchConnectivity", "Activation error: \(error.localizedDescription)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
    
    // MARK: - Watch
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.notification)
        #endif
        
        publisher.send(applicationContext)
        AppLogger.info(context: "WatchConnectivity", "didReceiveApplicationContext: \(applicationContext)")
    }
    
}
