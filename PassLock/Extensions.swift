//
//  Extensions.swift
//  PassLockDemo
//
//  Created by edison on 9/19/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit
import Foundation

// MARK: - String

extension String {
  var length: Int {
    return characters.count
  }
}

// MARK: - Shake

extension UIView {
  func shake(_ completion: (() -> Void)?) {
    CATransaction.begin()
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.1
    animation.repeatCount = 2
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 8.0, y: self.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 8.0, y: self.center.y))
    CATransaction.setCompletionBlock(completion)
    layer.add(animation, forKey: "position")
    CATransaction.commit()
  }
}
