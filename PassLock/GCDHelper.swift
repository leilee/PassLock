//
//  GCDHelper.swift
//  PassLockDemo
//
//  Created by edison on 9/22/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation

func delay(_ delay: TimeInterval, queue: DispatchQueue = DispatchQueue.main, closure:@escaping ()->()) {
  queue.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
