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

enum PassLockEvent {
  case Valid, Invalid
}

extension PassLockType {
  func nextEvent(x x: Password?, y: Password?, with state: PassLockState) -> PassLockEvent {
    switch (self, state) {
    case (.SetPassword, .Confirm), (.RemovePassword, .Input):
      return x == y ? .Valid : .Invalid
    default:
      return .Valid
    }
  }
}

extension PassLockViewController {

  func setPasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Input) { [weak self] state, event in
      switch (state, event) {
      case (.Input, .Valid): return (.Confirm, { _, _, info in
        // input => confirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info
      })
      case (.Confirm, .Valid): return (.Done, { _, _, _ in
        // confirm => done
        guard let strongSelf = self, let password = self?.currentPassword else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.delegate?.passLockController(strongSelf, setPassLockSucceed: password)
      })
      case (.Confirm, .Invalid): return (.Confirm, { _, _, _ in
        // reconfirm
        self?.passwordInputView.shake({ 
          self?.passwordInputView.clear()
          self?.descriptionLabel.text = "密码不匹配, 请再试一次"
          self?.descriptionLabel.hidden = false
        })
      })
      default: return nil
      }
    }
  }

  func changePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Input) { (state, event) in
      switch (state, event) {
      default: return nil
      }
    }
  }

  func removePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Input) { [weak self] (state, event) in
      switch (state, event) {
      case (.Input, .Valid): return (.Done, {  _, _, _ in
        // input => done
        guard let strongSelf = self else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.delegate?.passLockController(strongSelf, removePassLock: true)
      })
      case (.Input, .Invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // failure
          return (.Done, { _, _, _ in
            strongSelf.descriptionLabel.hidden = true
            strongSelf.delegate?.passLockController(strongSelf, removePassLock: false)
          })
        } else {
          // retry
          return (.Input, { _, _, _ in
            strongSelf.passwordInputView.shake({ 
              strongSelf.passwordInputView.clear()
              strongSelf.descriptionLabel.hidden = false
              strongSelf.descriptionLabel.text = "密码不匹配, 您还有\(strongSelf.config.retryCount - strongSelf.retryCount)次尝试机会"
            })
          })
        }
      default: return nil
      }
    }
  }

}
