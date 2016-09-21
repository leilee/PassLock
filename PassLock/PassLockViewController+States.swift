//
//  PassLockViewController+States.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

enum PassLockState {
  case Input, Confirm, Done
}

extension PassLockState {
  func validate(x: Password?, y: Password?) -> Bool {
    switch self {
    case .Input: return true
    case .Confirm: return x == y
    case .Done: return true
    }
  }
}

enum PassLockEvent {
  case Valid, Invalid
}

extension PassLockViewController {

  func setPasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Any> {
    return StateMachine<PassLockState, PassLockEvent, Any>(initialState: .Input) { (state, event) in
      switch (state, event) {
      case (.Input, .Valid): return (.Confirm, { [weak self] _, _, info in
        // input => confirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info as? String
      })
      case (.Confirm, .Valid): return (.Done, {[weak self] _, _, _ in
        // confirm => done
        self?.descriptionLabel.hidden = true
        self?.delegate?.setPassLockSuccess()
      })
      case (.Confirm, .Invalid): return (.Confirm, {[weak self] _, _, _ in
        // reconfirm
        self?.passwordInputView.clear()
        self?.descriptionLabel.text = "密码不匹配, 请再试一次"
        self?.descriptionLabel.hidden = false
      })
      default: return nil
      }
    }
  }

  func changePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Any> {
    return StateMachine<PassLockState, PassLockEvent, Any>(initialState: .Input) { (state, event) in
      switch (state, event) {
      default: return nil
      }
    }
  }

  func removePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Any> {
    return StateMachine<PassLockState, PassLockEvent, Any>(initialState: .Input) { (state, event) in
      switch (state, event) {
      default: return nil
      }
    }
  }

}
