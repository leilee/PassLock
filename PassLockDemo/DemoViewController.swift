//
//  PassLockSettingViewController.swift
//  shimo
//
//  Created by edison on 9/27/16.
//  Copyright © 2016 chuxin. All rights reserved.
//

import UIKit
import PassLock

struct PassLockHelper {
  
  private static let touchIDKey = "com.shimo.enableTouchID"
  
  static let keychain = Keychain(config: KeychainConfiguration())
  
  static var hasPassLock: Bool {
    return keychain.password() != nil
  }
  
  static func deletePassLock() {
    keychain.deletePassword()
    NSUserDefaults.standardUserDefaults().removeObjectForKey(touchIDKey)
  }
  
  static var enableTouchID: Bool {
    set(value) {
      NSUserDefaults.standardUserDefaults().setBool(value, forKey: touchIDKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(touchIDKey)
    }
  }
}

class DemoViewController: UITableViewController {
  
  @IBOutlet var enablePasswordSwitch: UISwitch!
  @IBOutlet var enableTouchIDSwitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "密码锁定"
    enablePasswordSwitch.on = PassLockHelper.hasPassLock
    enableTouchIDSwitch.on = PassLockHelper.enableTouchID
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return PassLockHelper.hasPassLock ? 2 : 1
    case 1:
      return PassLockHelper.hasPassLock && TouchID.enabled ? 1 : 0
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    switch (indexPath.section, indexPath.row) {
    case (0, 1): return indexPath
    default: return nil
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    switch (indexPath.section, indexPath.row) {
    case (0, 1):
      let config = PassLockConfiguration(keychainConfig: PassLockHelper.keychain.config, passLockType: .ChangePassword)
      let controller = PassLockViewController.instantiateViewController(configration: config)
      controller.delegate = self
      navigationController?.pushViewController(controller, animated: true)
    default:
      break
    }
  }
  
}

// MARK: - Action

extension DemoViewController {
  
  @IBAction func enablePasswordValueChanged(sender: UISwitch) {
    let flag = sender.on
    // UISwitch's function setOn(on: Bool, animated: Bool) send valueChange event in iOS 10
    // see also: http://stackoverflow.com/a/39725416/4661168
    dispatch_async(dispatch_get_main_queue()) { 
      sender.on = !flag
    }
    let type: PassLockType = flag ? .SetPassword : .RemovePassword
    let config = PassLockConfiguration(keychainConfig: PassLockHelper.keychain.config, passLockType: type)
    let controller = PassLockViewController.instantiateViewController(configration: config)
    controller.delegate = self
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func enableTouchIDValueChanged(sender: UISwitch) {
    PassLockHelper.enableTouchID = sender.on
  }
  
}

// MARK: - PassLockProtocol

extension DemoViewController: PassLockProtocol {
  
  func passLockController(passLockController: PassLockViewController, didSetPassLock result: Result<Password>) {
    switch result {
    case .Success(let password):
      print("set pass lock success: \(password)")
      enablePasswordSwitch.on = PassLockHelper.hasPassLock
      navigationController?.popViewControllerAnimated(true)
      tableView.reloadData()
    case .Failure:
      break
    }
  }
  
  func passLockController(passLockController: PassLockViewController, didChangePassLock result: Result<Password>) {
    switch result {
    case .Success(let password):
      print("change pass lock success: \(password)")
    case .Failure:
      print("change pass lock failure")
    }
    navigationController?.popViewControllerAnimated(true)
    tableView.reloadData()
  }
  
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result: Result<Any?>) {
    switch result {
    case .Success(_):
      print("remove pass lock success")
      enablePasswordSwitch.on = PassLockHelper.hasPassLock
    case .Failure:
      print("remove pass lock failure")
    }
    navigationController?.popViewControllerAnimated(true)
    tableView.reloadData()
  }
  
}
  