//
//  PassLockViewController+States.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

enum PassLockState {
  case Input, Confirm, Reconfirm, Done
}

enum PassLockEvent {
  case Valid, Invalid
}

extension PassLockState {
  func nextEvent(x x: Password?, y: Password?) -> PassLockEvent {
    switch self {
    case .Confirm, .Reconfirm:
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
        strongSelf.keychain?.setPassword(password)
        strongSelf.delegate?.passLockController(strongSelf, didSetPassLock: .Success(password))
      })
      case (.Confirm, .Invalid): return (.Confirm, { _, _, _ in
        // confirm again
        self?.descriptionLabel.text = "密码不匹配, 请再试一次"
        self?.descriptionLabel.hidden = false
        self?.passwordInputView.shake() {
          self?.passwordInputView.clear()
        }
      })
      default: return nil
      }
    }
  }

  func changePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Confirm) { [weak self] state, event in
      switch (state, event) {
      case (.Confirm, .Valid): return (.Input, { _, _, _ in
        // confirm => input
        self?.passwordInputView.clear()
        self?.titleLabel.text = "请输入新密码"
        self?.descriptionLabel.hidden = true
      })
      case (.Confirm, .Invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.Done, { _, _, _ in
            strongSelf.descriptionLabel.hidden = true
            strongSelf.delegate?.passLockController(strongSelf, didChangePassLock: .Failure)
          })
        } else {
          // retry
          return (.Confirm, { _, _, _ in
            strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            strongSelf.descriptionLabel.hidden = false
            strongSelf.passwordInputView.shake() {
              strongSelf.passwordInputView.clear()
            }
          })
        }
      case (.Input, .Valid): return (.Reconfirm, { _, _, info in
        // input => reconfirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info
      })
      case (.Reconfirm, .Valid): return (.Done, { _, _, info in
        // reconfirm => done
        guard let strongSelf = self, let password = self?.currentPassword else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.keychain?.setPassword(password)
        strongSelf.delegate?.passLockController(strongSelf, didChangePassLock: .Success(password))
      })
      case (.Reconfirm, .Invalid): return (.Reconfirm, { _, _, _ in
        // reconfirm again
        self?.descriptionLabel.text = "密码不匹配, 请再试一次"
        self?.descriptionLabel.hidden = false
        self?.passwordInputView.shake() {
          self?.passwordInputView.clear()
        }
      })
      default: return nil
      }
    }
  }

  func removePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Confirm) { [weak self] state, event in
      switch (state, event) {
      case (.Confirm, .Valid): return (.Done, {  _, _, _ in
        // confirm => done
        guard let strongSelf = self else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.keychain?.deletePassword()
        strongSelf.delegate?.passLockController(strongSelf, didRemovePassLock: .Success(nil))
      })
      case (.Confirm, .Invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.Done, { _, _, _ in
            strongSelf.descriptionLabel.hidden = true
            strongSelf.delegate?.passLockController(strongSelf, didRemovePassLock: .Failure)
          })
        } else {
          // retry
          return (.Confirm, { _, _, _ in
            strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            strongSelf.descriptionLabel.hidden = false
            strongSelf.passwordInputView.shake() {
              strongSelf.passwordInputView.clear()
            }
          })
        }
      default: return nil
      }
    }
  }
  
  func unlockStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .Confirm) { [weak self] state, event in
      switch (state, event) {
      case (.Confirm, .Valid): return (.Done, {  _, _, _ in
        // confirm => unlock
        guard let strongSelf = self else {
          return
        }
        strongSelf.descriptionLabel.hidden = true
        strongSelf.delegate?.passLockController(strongSelf, didUnlock: .Success(.Password))
      })
      case (.Confirm, .Invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.Done, { _, _, _ in
            strongSelf.descriptionLabel.hidden = true
            strongSelf.delegate?.passLockController(strongSelf, didUnlock: .Failure)
          })
        } else {
          // retry
          return (.Confirm, { _, _, _ in
            strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            strongSelf.descriptionLabel.hidden = false
            strongSelf.passwordInputView.shake() {
              strongSelf.passwordInputView.clear()
            }
          })
        }
      default: return nil
      }
    }
  }

}
