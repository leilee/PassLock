//
//  PassLockViewController.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public protocol PassLockProtocol: class {
  func setPassLockSuccess()
}

extension PassLockProtocol {
  // make functions optional
  func setPassLockSuccess() {}
}

public class PassLockViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var passwordInputView: PasswordInputView!

  public weak var delegate: PassLockProtocol?

  var config: PassLockConfiguration = PassLockConfiguration()
  var currentPassword: Password?
  var retryCount = 0

  lazy var stateMachine: StateMachine<PassLockState, PassLockEvent, Any> = {
    switch self.config.passLockType {
    case .SetPassword: return self.setPasswordStateMachine()
    case .ChangePassword: return self.changePasswordStateMachine()
    case .RemovePassword: return self.removePasswordStateMachine()
    }
  }()

  public class func instantiateViewController(configration config: PassLockConfiguration = PassLockConfiguration()) -> PassLockViewController {
    let storyboard = UIStoryboard(name: "PassLock", bundle: NSBundle(forClass: PassLockViewController.self))
    let controller = storyboard.instantiateViewControllerWithIdentifier("PassLockViewController") as! PassLockViewController
    controller.config = config
    controller.currentPassword = config.initialPassword
    return controller
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    // setup UI
    passwordInputView.delegate = self
    passwordInputView.becomeFirstResponder()
    
    titleLabel.text = "请输入密码"
    descriptionLabel.hidden = true
  }

}

extension PassLockViewController: PasswordInputProtocol {

  public func passwordInputComplete(passwordInputView: PasswordInputView, input: String) {
    let event: PassLockEvent = stateMachine.state.validate(currentPassword, y: input) ? .Valid : .Invalid
    stateMachine.handleEvent(event, info: input)
  }

}
