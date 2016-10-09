//
//  PassLockViewController.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public enum Result<T> {
  case success(T)
  case failure
}

public protocol PassLockProtocol: class {
  func passLockController(_ passLockController: PassLockViewController, didSetPassLock result: Result<Password>)
  func passLockController(_ passLockController: PassLockViewController, didChangePassLock result: Result<Password>)
  func passLockController(_ passLockController: PassLockViewController, didRemovePassLock result : Result<Any?>)
  func passLockController(_ passLockController: PassLockViewController, didUnlock result : Result<Any?>)
}

// make protocol functions optional
public extension PassLockProtocol {
  func passLockController(_ passLockController: PassLockViewController, didSetPassLock result: Result<Password>) {}
  func passLockController(_ passLockController: PassLockViewController, didChangePassLock result: Result<Password>) {}
  func passLockController(_ passLockController: PassLockViewController, didRemovePassLock result : Result<Any?>) {}
  func passLockController(_ passLockController: PassLockViewController, didUnlock result : Result<Any?>) {}
}

open class PassLockViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var passwordInputView: PasswordInputView!

  open weak var delegate: PassLockProtocol?

  var config: PassLockConfiguration = PassLockConfiguration()
  var currentPassword: Password?
  var keychain: Keychain?
  var retryCount = 0

  lazy var stateMachine: StateMachine<PassLockState, PassLockEvent, Password> = {
    switch self.config.passLockType {
    case .setPassword: return self.setPasswordStateMachine()
    case .changePassword: return self.changePasswordStateMachine()
    case .removePassword: return self.removePasswordStateMachine()
    case .unlock: return self.unlockStateMachine()
    }
  }()

  open class func instantiateViewController(configration config: PassLockConfiguration = PassLockConfiguration())
    -> PassLockViewController {
      let storyboard = UIStoryboard(name: "PassLock", bundle: Bundle(for: PassLockViewController.self))
      let controller = storyboard.instantiateViewController(withIdentifier: "PassLockViewController") as! PassLockViewController
      controller.config = config
      controller.keychain = Keychain(config: config.keychainConfig)
      controller.currentPassword = controller.keychain?.password()
      return controller
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    presentTouchIDIfNeeded()
    
    // dismiss on ApplicationBackground
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground,
                                                            object: nil,
                                                            queue: OperationQueue.main) { [weak self] _ in
                                                              self?.dismiss(animated: false, completion: nil)
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive,
                                                            object: nil,
                                                            queue: OperationQueue.main) { [weak self] _ in
                                                              self?.passwordInputView.becomeFirstResponder()
    }
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    passwordInputView.becomeFirstResponder()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

}

// MARK: - Presentable

extension PassLockViewController {
  
  public func present(animated flag: Bool, completion: (() -> Void)?) {
    guard !PassLockWindow.sharedInstance.isKeyWindow else {
      return
    }
    
    PassLockWindow.sharedInstance.makeKeyAndVisible()
    PassLockWindow.sharedInstance.rootViewController?.present(self, animated: flag, completion: completion)
  }
  
  open override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
    self.dismiss(animated: flag) { 
      PassLockWindow.sharedInstance.isHidden = true
      completion?()
    }
  }
  
}

// MARK: - PasswordInputProtocol

extension PassLockViewController: PasswordInputProtocol {

  public func passwordInputView(_ passwordInputView: PasswordInputView, inputComplete input: Password) {
    let event = stateMachine.state.nextEvent(x: currentPassword, y: input)
    stateMachine.handleEvent(event, info: input)
  }

}

// MARK: - Touch ID

extension PassLockViewController {
  
  fileprivate func presentTouchIDIfNeeded() {
    guard config.usingTouchID && TouchID.enabled else {
      return
    }
    
    func reason() -> String {
      if let displayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String {
        return "验证指纹解锁\(displayName)"
      } else if let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String {
        return "验证指纹解锁\(bundleName)"
      } else {
        return "验证指纹解锁"
      }
    }
    
    TouchID.presentTouchID(reason()) { success, error in
      if success {
        self.delegate?.passLockController(self, didUnlock: .success(nil))
      }
    }
  }
  
}

// MARK: - Private

extension PassLockViewController {
  
  fileprivate func setup() {
    passwordInputView.delegate = self
    
    titleLabel.text = config.passLockType.passwordInputTitle
    descriptionLabel.isHidden = true
    
    navigationItem.title = config.passLockType.title
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PassLockViewController.backgroundTapped))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc fileprivate func backgroundTapped() {
    passwordInputView.becomeFirstResponder()
  }
  
}
