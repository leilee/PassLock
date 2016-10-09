//
//  PasswordInputView.swift
//  PassLockDemo
//
//  Created by edison on 9/19/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public protocol PasswordInputProtocol: class {
  func passwordInputView(_ passwordInputView: PasswordInputView, inputComplete input: Password)
}

open class PasswordInputView: UIView {

  open weak var delegate: PasswordInputProtocol?

  open var keyboardType: UIKeyboardType = .numberPad

  @IBInspectable open var spacing: CGFloat = 6.0
  @IBInspectable open var strokeHeight: Int = 2
  @IBInspectable open var strokeColor: UIColor = UIColor.black
  @IBInspectable open var digit: Int = 4

  fileprivate var store = String() {
    didSet {
      for i in 0..<store.length {
        strokeViews[i].isHidden = true
        dotViews[i].isHidden = false
      }
      for j in store.length..<digit {
        strokeViews[j].isHidden = false
        dotViews[j].isHidden = true
      }
      if store.length == digit {
        // 输入密码后, delay 0.1s 再回调 delegate
        // 否则最后一位密码的 UI 来不及刷新
        delay(0.1) {
          self.delegate?.passwordInputView(self, inputComplete: self.store)
        }
      }
    }
  }

  fileprivate var strokeViews = [UIView]()
  fileprivate var dotViews = [UIView]()

  open override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    dotViews.forEach { (dot) in
      let width = dot.frame.width
      dot.layer.cornerRadius = width / 2.0
      dot.clipsToBounds = true
    }
  }

}

// MARK: - UIKeyInput

extension PasswordInputView: UIKeyInput {

  public func insertText(_ text: String) {
    guard store.length + text.length <= digit else {
      return
    }
    store.append(text)
  }

  public func deleteBackward() {
    guard hasText else {
      return
    }
    store.remove(at: store.characters.index(before: store.endIndex))
  }

  public var hasText : Bool {
    return store.characters.count > 0
  }

  override open var canBecomeFirstResponder : Bool {
    return true
  }

}

// MARK: - Public

extension PasswordInputView {

  public func clear() {
    store = ""
  }

}

// MARK: - Private

extension PasswordInputView {

  fileprivate final func setup() {
    guard digit > 0 && strokeHeight > 0 else {
      return
    }

    strokeViews.forEach { $0.removeFromSuperview() }
    strokeViews.removeAll()
    dotViews.forEach { $0.removeFromSuperview() }
    dotViews.removeAll()

    for _ in 0..<digit {
      let stroke = UIView()
      stroke.translatesAutoresizingMaskIntoConstraints = false
      stroke.backgroundColor = strokeColor
      strokeViews.append(stroke)
      addSubview(stroke)

      let dot = UIView()
      dot.translatesAutoresizingMaskIntoConstraints = false
      dot.backgroundColor = strokeColor
      dot.isHidden = true
      dotViews.append(dot)
      addSubview(dot)
    }

    // layout stroke
    var strokeDict = [String : AnyObject]()
    var strokeFormatString = ""
    strokeViews.enumerated().forEach { (index, stroke) in
      strokeDict["stroke\(index)"] = stroke

      if index == 0 {
        strokeFormatString += "H:|[stroke0]"
      } else {
        strokeFormatString += "-space@250-[stroke\(index)(==stroke0)]"
      }
      if index == digit - 1 {
        strokeFormatString += "|"
      }

      // vertical
      addConstraint(NSLayoutConstraint(item: stroke, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: stroke, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(strokeHeight)))
    }

    // horizontal
    let metrics = ["space": spacing]
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: strokeFormatString, options: .directionLeftToRight, metrics: metrics, views: strokeDict))

    // layout dot
    dotViews.enumerated().forEach { (index, dot) in
      let stroke = strokeViews[index]
      addConstraint(NSLayoutConstraint(item: dot, attribute: .centerX, relatedBy: .equal, toItem: stroke, attribute: .centerX, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: dot, attribute: .centerY, relatedBy: .equal, toItem: stroke, attribute: .centerY, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: dot, attribute: .width, relatedBy: .equal, toItem: stroke, attribute: .width, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: dot, attribute: .height, relatedBy: .equal, toItem: dot, attribute: .width, multiplier: 1, constant: 0))
    }
  }

}
