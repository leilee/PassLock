//
//  PassLockViewController.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public enum Result<T> {
  case Success(T)
  case Failure
}

public protocol PassLockProtocol: class {
  func passLockController(passLockController: PassLockViewController, didSetPassLock result: Result<Password>)
  func passLockController(passLockController: PassLockViewController, didChangePassLock result: Result<Password>)
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result : Result<Any?>)
  func passLockController(passLockController: PassLockViewController, didUnlock result : Result<Any?>)
}

// make protocol functions optional
public extension PassLockProtocol {
  func passLockController(passLockController: PassLockViewController, didSetPassLock result: Result<Password>) {}
  func passLockController(passLockController: PassLockViewController, didChangePassLock result: Result<Password>) {}
  func passLockController(passLockController: PassLockViewController, didRemovePassLock result : Result<Any?>) {}
  func passLockController(passLockController: PassLockViewController, didUnlock result : Result<Any?>) {}
}

public class PassLockViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var passwordInputView: PasswordInputView!

  public weak var delegate: PassLockProtocol?

  var config: PassLockConfiguration = PassLockConfiguration()
  var currentPassword: Password?
  var keychain: Keychain?
  var retryCount = 0

  lazy var stateMachine: StateMachine<PassLockState, PassLockEvent, Password> = {
    switch self.config.passLockType {
    case .SetPassword: return self.setPasswordStateMachine()
    case .ChangePassword: return self.changePasswordStateMachine()
    case .RemovePassword: return self.removePasswordStateMachine()
    case .Unlock: return self.unlockStateMachine()
    }
  }()

  public class func instantiateViewController(configration config: PassLockConfiguration = PassLockConfiguration())
    -> PassLockViewController {
      let storyboard = UIStoryboard(name: "PassLock", bundle: NSBundle(forClass: PassLockViewController.self))
      let controller = storyboard.instantiateViewControllerWithIdentifier("PassLockViewController") as! PassLockViewController
      controller.config = config
      controller.keychain = Keychain(config: config.keychainConfig)
      controller.currentPassword = controller.keychain?.password()
      return controller
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    presentTouchIDIfNeeded()
    
    // dismiss on ApplicationBackground
    NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification,
                                                            object: nil,
                                                            queue: NSOperationQueue.mainQueue()) { [weak self] _ in
                                                              self?.dismiss(animated: false, completion: nil)
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification,
                                                            object: nil,
                                                            queue: NSOperationQueue.mainQueue()) { [weak self] _ in
                                                              self?.passwordInputView.becomeFirstResponder()
    }
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    passwordInputView.becomeFirstResponder()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

}

// MARK: - Presentable

extension PassLockViewController {
  
  public func present(animated flag: Bool, completion: (() -> Void)?) {
    guard !PassLockWindow.sharedInstance.keyWindow else {
      return
    }
    
    PassLockWindow.sharedInstance.makeKeyAndVisible()
    PassLockWindow.sharedInstance.rootViewController?.presentViewController(self, animated: flag, completion: completion)
  }
  
  public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
    self.dismissViewControllerAnimated(flag) { 
      PassLockWindow.sharedInstance.hidden = true
      completion?()
    }
  }
  
}

// MARK: - PasswordInputProtocol

extension PassLockViewController: PasswordInputProtocol {

  public func passwordInputView(passwordInputView: PasswordInputView, inputComplete input: Password) {
    let event = stateMachine.state.nextEvent(x: currentPassword, y: input)
    stateMachine.handleEvent(event, info: input)
  }

}

// MARK: - Touch ID

extension PassLockViewController {
  
  private func presentTouchIDIfNeeded() {
    guard config.usingTouchID && TouchID.enabled else {
      return
    }
    
    func reason() -> String {
      if let displayName = NSBundle.mainBundle().infoDictionary!["CFBundleDisplayName"] as? String {
        return "验证指纹解锁\(displayName)"
      } else if let bundleName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String {
        return "验证指纹解锁\(bundleName)"
      } else {
        return "验证指纹解锁"
      }
    }
    
    TouchID.presentTouchID(reason()) { success, error in
      if success {
        self.delegate?.passLockController(self, didUnlock: .Success(nil))
      }
    }
  }
  
}

// MARK: - Private

extension PassLockViewController {
  
  private func setup() {
    passwordInputView.delegate = self
    
    titleLabel.text = config.passLockType.passwordInputTitle
    descriptionLabel.hidden = true
    
    navigationItem.title = config.passLockType.title
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PassLockViewController.backgroundTapped))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func backgroundTapped() {
    passwordInputView.becomeFirstResponder()
  }
  
}
