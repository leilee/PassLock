//
//  Keychain.swift
//  PassLockDemo
//
//  Created by edison on 9/26/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation
import Security

public struct Keychain {
  
  public let account: String
  public let service: String
  public let accessGroup: String?
  
  private var keychainQuery: [String : AnyObject] {
    var query = [String : AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrAccount as String] = account
    query[kSecAttrService as String] = service
    if let accessGroup = accessGroup {
      query[kSecAttrAccessGroup as String] = accessGroup
    }
    
    return query
  }
  
  init(account: String, service: String = "com.nscodemonkey.passlock", accessGroup: String? = nil) {
    self.account = account
    self.service = service
    self.accessGroup = accessGroup
  }
  
}

// MARK: - Password

extension Keychain {
  
  public var password: String? {
    set(value) {
      guard let value = value else {
        deletePassword()
        return
      }
      
      let encodedPassword = value.dataUsingEncoding(NSUTF8StringEncoding)
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
      
    }
    get {
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
  }
  
  private func deletePassword() -> Bool {
    let status = SecItemDelete(keychainQuery)
    return status == noErr
  }
  
}