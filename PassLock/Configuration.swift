//
//  Config.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation

public typealias Password = String

public enum UnlockBy {
  case Password, TouchID
}

public enum PassLockType {
  case SetPassword
  case ChangePassword
  case RemovePassword
  case Unlock
}

extension PassLockType {
  
  var title: String? {
    switch self {
    case .SetPassword: return "设置密码"
    case .RemovePassword: return "关闭密码"
    case .ChangePassword: return "更改密码"
    default: return nil
    }
  }
  
  var passwordInputTitle: String {
    switch self {
    case .SetPassword, .RemovePassword, .Unlock: return "请输入密码"
    case .ChangePassword: return "请输入旧密码"
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
  let keychainConfig: KeychainConfiguration
  let retryCount: Int
  let usingTouchID: Bool
  let passLockType: PassLockType

  public init(passwordConfig: PasswordViewConfiguration = PasswordViewConfiguration(),
              keychainConfig: KeychainConfiguration = KeychainConfiguration(),
              retryCount: Int = 5,
              usingTouchID: Bool = false,
              passLockType: PassLockType = .SetPassword) {
    self.passwordConfig = passwordConfig
    self.keychainConfig = keychainConfig
    self.retryCount = retryCount
    self.usingTouchID = usingTouchID
    self.passLockType = passLockType
  }
  
}
