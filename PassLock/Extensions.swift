//
//  Extensions.swift
//  PassLockDemo
//
//  Created by edison on 9/19/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation
import UIKit

// MARK: - String

extension String {
  var length: Int {
    return characters.count
  }
}

// MARK: - Shake

extension UIView {
  func shake(completion: (() -> Void)?) {
    CATransaction.begin()
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.1
    animation.repeatCount = 2
    animation.autoreverses = true
    animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 8.0, self.center.y))
    animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 8.0, self.center.y))
    CATransaction.setCompletionBlock(completion)
    layer.addAnimation(animation, forKey: "position")
    CATransaction.commit()
  }
}
