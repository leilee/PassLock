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
  case setPassword
  case changePassword
  case removePassword
  case unlock
}

extension PassLockType {
  
  var title: String? {
    switch self {
    case .setPassword: return "设置密码"
    case .removePassword: return "关闭密码"
    case .changePassword: return "更改密码"
    default: return nil
    }
  }
  
  var passwordInputTitle: String {
    switch self {
    case .setPassword, .removePassword, .unlock: return "请输入密码"
    case .changePassword: return "请输入旧密码"
    }
  }
  
}

public struct PasswordViewConfiguration {
  let digit: Int
  let spacing: CGFloat
  let strokeHeight: CGFloat
  let strokeColor: UIColor

  init(digit: Int = 4, spacing: CGFloat = 20, strokeHeight: CGFloat = 2, strokeColor: UIColor = UIColor.black) {
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
              passLockType: PassLockType = .setPassword) {
    self.passwordConfig = passwordConfig
    self.keychainConfig = keychainConfig
    self.retryCount = retryCount
    self.usingTouchID = usingTouchID
    self.passLockType = passLockType
  }
  
}
