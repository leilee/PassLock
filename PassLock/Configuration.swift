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
}

extension PassLockType {
  public var title: String {
    switch self {
    case .SetPassword: return "请输入密码"
    case .ChangePassword, .RemovePassword: return "请输入旧密码"
    }
  }
}

public struct PasswordConfiguration {
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
  let passwordConfig: PasswordConfiguration
  let retryCount: Int
  let passLockType: PassLockType
  let initialPassword: Password?

  public init(passwordConfig: PasswordConfiguration = PasswordConfiguration(),
       retryCount: Int = 5,
       passLockType: PassLockType = .SetPassword,
       initialPassword: Password? = nil) {
    self.passwordConfig = passwordConfig
    self.retryCount = retryCount
    self.passLockType = passLockType
    self.initialPassword = initialPassword
  }
}
