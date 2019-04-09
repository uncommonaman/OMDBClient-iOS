//
//  File.swift
//  OMDBClient
//
//  Created by Amandeep on 08/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation


public class SynchronizedDictionary<K:Hashable,V> {
    private var dictionary: [K:V] = [:]
    private let accessQueue = DispatchQueue(label: "SynchronizedDictionaryAccess", attributes: .concurrent)
    
    public func add(value: V,key:K) {
        self.accessQueue.async(flags:.barrier) {
            self.dictionary[key] = value
        }
    }
    
    public func removeValue(key: K) {
        self.accessQueue.async(flags:.barrier) {
            self.dictionary.removeValue(forKey: key)
        }
    }
    
    
    public func valueFor(key:K) -> V? {
        var element: V?
        
       self.accessQueue.sync {
             element = self.dictionary[key]
        }
        
        return element
    }
    
}
