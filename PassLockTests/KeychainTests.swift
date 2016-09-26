//
//  KeychainTests.swift
//  PassLockDemo
//
//  Created by edison on 9/26/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import XCTest
@testable import PassLock

class KeychainTests: XCTestCase {
  
  let keychain = Keychain(config: KeychainConfiguration())
  let password = "asldkfjlas9283140]]]])(*)"
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    keychain.deletePassword()
  }
  
  func testExample() {
    // test setter
    XCTAssertTrue(keychain.setPassword(password))
    
    // test getter
    XCTAssertEqual(password, keychain.password())
    
    // test update
    let newPassword = "3ed7jeka@$^"
    keychain.setPassword(newPassword)
    XCTAssertEqual(newPassword, keychain.password())
    
    // test delete
    keychain.deletePassword()
    XCTAssertNil(keychain.password())
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
}
