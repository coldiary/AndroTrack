//
//  Collection+Extension.swift
//  AndroTrack (iOS)
//
//  Created by Benoit Sida on 2022-04-19.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
