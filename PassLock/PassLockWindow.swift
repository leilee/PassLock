//
//  PassLockWindow.swift
//  PassLockDemo
//
//  Created by edison on 9/26/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

class PassLockWindow: UIWindow {
  
  static let sharedInstance = PassLockWindow()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  convenience init() {
    self.init(frame: UIScreen.mainScreen().bounds)
    self.rootViewController = UIViewController()
    self.windowLevel = UIWindowLevelAlert + 1
  }
  
}
