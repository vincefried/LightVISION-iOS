//
//  Observable.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 30.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

typealias Observer = NSObject

class Observable<T> {
    
    var observers = [(observer: Observer, delegate: T)]()
    
    public func addObserver(_ observer: Observer, delegate: T) {
        observers.append((observer, delegate))
    }
    
    public func unbind(observer: Observer) {
        observers.removeAll { $0.observer == observer }
    }
}
