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
  
  fileprivate static let touchIDKey = "com.shimo.enableTouchID"
  
  static let keychain = Keychain(config: KeychainConfiguration())
  
  static var hasPassLock: Bool {
    return keychain.password() != nil
  }
  
  static func deletePassLock() {
    keychain.deletePassword()
    UserDefaults.standard.removeObject(forKey: touchIDKey)
  }
  
  static var enableTouchID: Bool {
    set(value) {
      UserDefaults.standard.set(value, forKey: touchIDKey)
      UserDefaults.standard.synchronize()
    }
    get {
      return UserDefaults.standard.bool(forKey: touchIDKey)
    }
  }
}

class DemoViewController: UITableViewController {
  
  @IBOutlet var enablePasswordSwitch: UISwitch!
  @IBOutlet var enableTouchIDSwitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "密码锁定"
    enablePasswordSwitch.isOn = PassLockHelper.hasPassLock
    enableTouchIDSwitch.isOn = PassLockHelper.enableTouchID
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return PassLockHelper.hasPassLock ? 2 : 1
    case 1:
      return PassLockHelper.hasPassLock && TouchID.enabled ? 1 : 0
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
    case (0, 1): return indexPath
    default: return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
    case (0, 1):
      let config = PassLockConfiguration(keychainConfig: PassLockHelper.keychain.config, passLockType: .changePassword)
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
  
  @IBAction func enablePasswordValueChanged(_ sender: UISwitch) {
    let flag = sender.isOn
    // UISwitch's function setOn(on: Bool, animated: Bool) send valueChange event in iOS 10
    // see also: http://stackoverflow.com/a/39725416/4661168
    DispatchQueue.main.async { 
      sender.isOn = !flag
    }
    let type: PassLockType = flag ? .setPassword : .removePassword
    let config = PassLockConfiguration(keychainConfig: PassLockHelper.keychain.config, passLockType: type)
    let controller = PassLockViewController.instantiateViewController(configration: config)
    controller.delegate = self
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func enableTouchIDValueChanged(_ sender: UISwitch) {
    PassLockHelper.enableTouchID = sender.isOn
  }
  
}

// MARK: - PassLockProtocol

extension DemoViewController: PassLockProtocol {
  
  func passLockController(_ passLockController: PassLockViewController, didSetPassLock result: Result<Password>) {
    switch result {
    case .success(let password):
      print("set pass lock success: \(password)")
      enablePasswordSwitch.isOn = PassLockHelper.hasPassLock
      navigationController?.popViewController(animated: true)
      tableView.reloadData()
    case .failure:
      break
    }
  }
  
  func passLockController(_ passLockController: PassLockViewController, didChangePassLock result: Result<Password>) {
    switch result {
    case .success(let password):
      print("change pass lock success: \(password)")
    case .failure:
      print("change pass lock failure")
    }
    navigationController?.popViewController(animated: true)
    tableView.reloadData()
  }
  
  func passLockController(_ passLockController: PassLockViewController, didRemovePassLock result: Result<Any?>) {
    switch result {
    case .success(_):
      print("remove pass lock success")
      enablePasswordSwitch.isOn = PassLockHelper.hasPassLock
    case .failure:
      print("remove pass lock failure")
    }
    navigationController?.popViewController(animated: true)
    tableView.reloadData()
  }
  
}
  
