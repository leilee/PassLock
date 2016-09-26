//
//  Config.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation

public typealias Password = String

public enum PassLockType {
  case SetPassword
  case ChangePassword
  case RemovePassword
  case Unlock
}

extension PassLockType {
  public var title: String {
    switch self {
    case .SetPassword, .Unlock: return "请输入密码"
    case .ChangePassword, .RemovePassword: return "请输入旧密码"
    }
  }
}

public struct PasswordViewConfiguration {
  let digit: Int
  let spacing: CGFloat
  let strokeHeight: CGFloat
  let strokeColor: UIColor

  init(digit: Int = 4, spacing: CGFloat = 20, strokeHeight: CGFloat = 2, strokeColor: UIColor = UIColor.blackColor()) {
    self.digit = digit
    self.spacing = spacing
    self.strokeHeight = strokeHeight
    self.strokeColor = strokeColor
  }
}

public struct PassLockConfiguration {
  let passwordConfig: PasswordViewConfiguration
  let retryCount: Int
  let usingTouchID: Bool
  let passLockType: PassLockType
  let initialPassword: Password?

  public init(passwordConfig: PasswordViewConfiguration = PasswordViewConfiguration(),
       retryCount: Int = 5,
       usingTouchID: Bool = false,
       passLockType: PassLockType = .SetPassword,
       initialPassword: Password? = nil) {
    self.passwordConfig = passwordConfig
    self.retryCount = retryCount
    self.usingTouchID = usingTouchID
    self.passLockType = passLockType
    self.initialPassword = initialPassword
  }
}
