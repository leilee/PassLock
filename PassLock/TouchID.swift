//
//  TouchID.swift
//  PassLockDemo
//
//  Created by edison on 9/26/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct TouchID {
  
  public static var enabled: Bool {
    return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  public static func presentTouchID(_ reason: String, fallbackTitle: String? = nil, callback: @escaping (Bool, NSError?) -> Void) {
    let context = LAContext()
    context.localizedFallbackTitle = fallbackTitle
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
      DispatchQueue.main.async(execute: { 
        callback(success, error as NSError?)
      })
    }
  }
  
}
