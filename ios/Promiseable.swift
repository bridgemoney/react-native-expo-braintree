//
//  Promiseable.swift
//  Pods
//
//  Created by Mikhail Chachkouski on 22.12.24.
//

import Foundation
import React

protocol Promiseable {
  var resolve: RCTPromiseResolveBlock? { get set }
  var reject: RCTPromiseRejectBlock? { get set }
  
  func resetPromises() -> Void
}
