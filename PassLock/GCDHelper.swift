//
//  GCDHelper.swift
//  PassLockDemo
//
//  Created by edison on 9/22/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation

func delay(delay: NSTimeInterval, queue: dispatch_queue_t = dispatch_get_main_queue(), closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    queue, closure)
}
