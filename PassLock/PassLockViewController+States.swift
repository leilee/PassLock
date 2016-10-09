//
//  PassLockViewController+States.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

enum PassLockState {
  case input, confirm, reconfirm, done
}

enum PassLockEvent {
  case valid, invalid
}

extension PassLockState {
  func nextEvent(x: Password?, y: Password?) -> PassLockEvent {
    switch self {
    case .confirm, .reconfirm:
      return x == y ? .valid : .invalid
    default:
      return .valid
    }
  }
}

extension PassLockViewController {

  func setPasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .input) { [weak self] state, event in
      switch (state, event) {
      case (.input, .valid): return (.confirm, { _, _, info in
        // input => confirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info
      })
      case (.confirm, .valid): return (.done, { _, _, _ in
        // confirm => done
        guard let strongSelf = self, let password = self?.currentPassword else {
          return
        }
        strongSelf.descriptionLabel.isHidden = true
        strongSelf.keychain?.setPassword(password)
        strongSelf.delegate?.passLockController(strongSelf, didSetPassLock: .success(password))
      })
      case (.confirm, .invalid): return (.confirm, { _, _, _ in
        // confirm again
        self?.descriptionLabel.text = "密码不匹配, 请再试一次"
        self?.descriptionLabel.isHidden = false
        self?.passwordInputView.shake() {
          self?.passwordInputView.clear()
        }
      })
      default: return nil
      }
    }
  }

  func changePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .confirm) { [weak self] state, event in
      switch (state, event) {
      case (.confirm, .valid): return (.input, { _, _, _ in
        // confirm => input
        self?.passwordInputView.clear()
        self?.titleLabel.text = "请输入新密码"
        self?.descriptionLabel.isHidden = true
      })
      case (.confirm, .invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.done, { _, _, _ in
            strongSelf.descriptionLabel.isHidden = true
            strongSelf.delegate?.passLockController(strongSelf, didChangePassLock: .failure)
          })
        } else {
          // retry
          return (.confirm, { _, _, _ in
            strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            strongSelf.descriptionLabel.isHidden = false
            strongSelf.passwordInputView.shake() {
              strongSelf.passwordInputView.clear()
            }
          })
        }
      case (.input, .valid): return (.reconfirm, { _, _, info in
        // input => reconfirm
        self?.titleLabel.text = "验证密码"
        self?.passwordInputView.clear()
        self?.currentPassword = info
      })
      case (.reconfirm, .valid): return (.done, { _, _, info in
        // reconfirm => done
        guard let strongSelf = self, let password = self?.currentPassword else {
          return
        }
        strongSelf.descriptionLabel.isHidden = true
        strongSelf.keychain?.setPassword(password)
        strongSelf.delegate?.passLockController(strongSelf, didChangePassLock: .success(password))
      })
      case (.reconfirm, .invalid): return (.reconfirm, { _, _, _ in
        // reconfirm again
        self?.descriptionLabel.text = "密码不匹配, 请再试一次"
        self?.descriptionLabel.isHidden = false
        self?.passwordInputView.shake() {
          self?.passwordInputView.clear()
        }
      })
      default: return nil
      }
    }
  }

  func removePasswordStateMachine() -> StateMachine<PassLockState, PassLockEvent, Password> {
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .confirm) { [weak self] state, event in
      switch (state, event) {
      case (.confirm, .valid): return (.done, {  _, _, _ in
        // confirm => done
        guard let strongSelf = self else {
          return
        }
        strongSelf.descriptionLabel.isHidden = true
        strongSelf.keychain?.deletePassword()
        strongSelf.delegate?.passLockController(strongSelf, didRemovePassLock: .success(nil))
      })
      case (.confirm, .invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.done, { _, _, _ in
            strongSelf.descriptionLabel.isHidden = true
            strongSelf.delegate?.passLockController(strongSelf, didRemovePassLock: .failure)
          })
        } else {
          // retry
          return (.confirm, { _, _, _ in
            strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            strongSelf.descriptionLabel.isHidden = false
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
    return StateMachine<PassLockState, PassLockEvent, Password>(initialState: .confirm) { [weak self] state, event in
      switch (state, event) {
      case (.confirm, .valid): return (.done, {  _, _, _ in
        // confirm => unlock
        guard let strongSelf = self else {
          return
        }
        strongSelf.descriptionLabel.isHidden = true
        strongSelf.delegate?.passLockController(strongSelf, didUnlock: .success(nil))
      })
      case (.confirm, .invalid):
        guard let strongSelf = self else {
          return nil
        }
        strongSelf.retryCount += 1
        if strongSelf.retryCount >= strongSelf.config.retryCount {
          // exceed retry count, failure
          return (.done, { _, _, _ in
            strongSelf.descriptionLabel.isHidden = true
            strongSelf.delegate?.passLockController(strongSelf, didUnlock: .failure)
          })
        } else {
          // retry
          return (.confirm, { _, _, _ in
            strongSelf.descriptionLabel.text = "密码不匹配, 您还有 \(strongSelf.config.retryCount - strongSelf.retryCount) 次尝试机会"
            strongSelf.descriptionLabel.isHidden = false
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
