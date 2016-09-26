//
//  TableViewController.swift
//  PassLockDemo
//
//  Created by edison on 9/21/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit
import PassLock

struct UserDefaults {
  static let enableTouchIDKey = "com.nscodemonkey.passlockdemo.enableTouchID"
  
  static func isTouchIDEnabled() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(enableTouchIDKey)
  }
}

struct PassLock {
  static let keychain = Keychain(config: KeychainConfiguration())
  
  static var hasPassword: Bool {
    return keychain.password() != nil
  }
}

class TableViewController: UITableViewController {

  @IBOutlet var enablePasswordSwitch: UISwitch!
  @IBOutlet var enableTouchIDSwitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    enablePasswordSwitch.on = PassLock.hasPassword
    enableTouchIDSwitch.on = UserDefaults.isTouchIDEnabled()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (0, 1):
      let config = PassLockConfiguration(passLockType: .ChangePassword)
      let controller = PassLockViewController.instantiateViewController(configration: config)
      controller.delegate = self
      navigationController?.pushViewController(controller, animated: true)
    default:
      break
    }
  }

}

// MARK: - PassLockProtocol

extension TableViewController: PassLockProtocol {
  
  func passLockController(passLockController: PassLockViewController, didSetPassLock result: Result<Password>) {
    switch result {
    case .Success(let password):
      print("set pass lock success: \(password)")
      enablePasswordSwitch.on = PassLock.hasPassword
      navigationController?.popViewControllerAnimated(true)
    case .Failure:
      break
    }
  }
  
  func passLockController(passLockController: PassLockViewController, didChangePassLock result: Result<Password>) {
    switch result {
    case .Success(let password):
      print("change pass lock success: \(password)")
      navigationController?.popViewControllerAnimated(true)
    case .Failure:
      print("change pass lock failure")
      let alert = UIAlertController(title: "Go Die", message: "Change Password Failure", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      navigationController?.popViewControllerAnimated(true)
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result: Result<Any?>) {
    switch result {
    case .Success(_):
      print("remove pass lock success")
      enablePasswordSwitch.on = PassLock.hasPassword
      navigationController?.popViewControllerAnimated(true)
    case .Failure:
      print("remove pass lock failure")
      let alert = UIAlertController(title: "Go Die", message: "Remove Password Failure", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      navigationController?.popViewControllerAnimated(true)
      presentViewController(alert, animated: true, completion: nil)
    }
  }
  
}

// MARK: - Action

extension TableViewController {
  
  @IBAction func enablePasswordValueChanged(sender: AnyObject) {
    let type: PassLockType = (sender as! UISwitch).on ? .SetPassword : .RemovePassword
    (sender as! UISwitch).on = !(sender as! UISwitch).on
    let config = PassLockConfiguration(passLockType: type)
    let controller = PassLockViewController.instantiateViewController(configration: config)
    controller.delegate = self
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func enableTouchIDValueChanged(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().setBool((sender as! UISwitch).on, forKey: UserDefaults.enableTouchIDKey)
  }
  
}