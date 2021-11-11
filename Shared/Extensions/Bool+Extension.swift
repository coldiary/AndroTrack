//
//  Bool+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2021-09-29.
//

import Foundation

extension Bool {
     static var isiOS15: Bool {
         if #available(iOS 15.0, *) {
             return true
         } else {
             return false
         }
     }
 }
