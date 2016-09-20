//
//  PassLockViewController.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public class PassLockViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var passwordInputView: PasswordInputView!
  
  private var config: PassLockConfiguration!

  public class func instantiateViewController(configration config: PassLockConfiguration = PassLockConfiguration()) -> PassLockViewController {
    let storyboard = UIStoryboard(name: "PassLock", bundle: NSBundle(forClass: PassLockViewController.self))
    let controller = storyboard.instantiateViewControllerWithIdentifier("PassLockViewController") as! PassLockViewController
    controller.config = config
    return controller
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    passwordInputView.becomeFirstResponder()
  }

}
