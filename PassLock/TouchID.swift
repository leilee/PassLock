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
    return LAContext().canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func presentTouchID(reason: String, fallbackTitle: String? = nil, callback: (Bool, NSError?) -> Void) {
    let context = LAContext()
    context.localizedFallbackTitle = fallbackTitle
    context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
      dispatch_async(dispatch_get_main_queue(), { 
        callback(success, error)
      })
    }
  }
  
}
