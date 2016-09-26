//
//  Keychain.swift
//  PassLockDemo
//
//  Created by edison on 9/26/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation
import Security

public struct KeychainConfiguration {
  public let account: String
  public let service: String
  public let accessGroup: String?
  
  public init(account: String = "password",
       service: String = "com.nscodemonkey.passlock",
       accessGroup: String? = nil) {
    self.account = account
    self.service = service
    self.accessGroup = accessGroup
  }
  
}

public struct Keychain {
  
  public let config: KeychainConfiguration
  
  private var keychainQuery: [String : AnyObject] {
    var query = [String : AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrAccount as String] = config.account
    query[kSecAttrService as String] = config.service
    if let accessGroup = config.accessGroup {
      query[kSecAttrAccessGroup as String] = accessGroup
    }
    
    return query
  }
  
  public init(config: KeychainConfiguration) {
    self.config = config
  }
  
}

// MARK: - Password

extension Keychain {
  
  public func password() -> String? {
    var query = keychainQuery
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    query[kSecReturnData as String] = kCFBooleanTrue
    
    var result: AnyObject?
    let status = withUnsafeMutablePointer(&result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    guard status == noErr else {
      return nil
    }
    
    guard let queryResult = result as? [String : AnyObject],
      let passwordData = queryResult[kSecValueData as String] as? NSData,
      let password = String(data: passwordData, encoding: NSUTF8StringEncoding)
      else {
        return nil
    }
    
    return password
  }
  
  public func setPassword(password: String) -> Bool {
    let encodedPassword = password.dataUsingEncoding(NSUTF8StringEncoding)
    var status = SecItemCopyMatching(keychainQuery, nil)
    var attributes = [String : AnyObject]()
    
    switch status {
    case noErr:
      attributes[kSecValueData as String] = encodedPassword
      status = SecItemUpdate(keychainQuery, attributes)
    case errSecItemNotFound:
      var query = keychainQuery
      query[kSecValueData as String] = encodedPassword
      status = SecItemAdd(query, nil)
    default: break
    }
    
    return status == noErr
  }
  
  public func deletePassword() -> Bool {
    let status = SecItemDelete(keychainQuery)
    return status == noErr
  }
  
}