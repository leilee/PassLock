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
  static let passwordKey = "com.nscodemonkey.passlockdemo.password"
  static func hasPassword() -> Bool {
    return NSUserDefaults.standardUserDefaults().objectForKey(passwordKey) != nil
  }
}

class TableViewController: UITableViewController {

  @IBOutlet var enablePasswordSwitch: UISwitch!
  @IBOutlet var enableTouchIDSwitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    enablePasswordSwitch.on = UserDefaults.hasPassword()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.row {
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
      NSUserDefaults.standardUserDefaults().setObject(password, forKey: UserDefaults.passwordKey)
      enablePasswordSwitch.on = UserDefaults.hasPassword()
      navigationController?.popViewControllerAnimated(true)
    case .Failure:
      break
    }
  }
  
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result: Result<Any?>) {
    switch result {
    case .Success(_):
      print("remove pass lock success")
      NSUserDefaults.standardUserDefaults().setObject(nil, forKey: UserDefaults.passwordKey)
      enablePasswordSwitch.on = UserDefaults.hasPassword()
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
    let password = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaults.passwordKey) as? String
    let config = PassLockConfiguration(passLockType: type, initialPassword: password)
    let controller = PassLockViewController.instantiateViewController(configration: config)
    controller.delegate = self
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func enableTouchIDValueChanged(sender: AnyObject) {
  }
  
}