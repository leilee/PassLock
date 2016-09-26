//
//  PasswordInputView.swift
//  PassLockDemo
//
//  Created by edison on 9/19/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import UIKit

public protocol PasswordInputProtocol: class {
  func passwordInputView(passwordInputView: PasswordInputView, inputComplete input: Password)
}

public class PasswordInputView: UIView {

  public weak var delegate: PasswordInputProtocol?

  public var keyboardType: UIKeyboardType = .NumberPad

  @IBInspectable public var spacing: CGFloat = 6.0
  @IBInspectable public var strokeHeight: Int = 2
  @IBInspectable public var strokeColor: UIColor = UIColor.blackColor()
  @IBInspectable public var digit: Int = 4

  private var store = String() {
    didSet {
      for i in 0..<store.length {
        strokeViews[i].hidden = true
        dotViews[i].hidden = false
      }
      for j in store.length..<digit {
        strokeViews[j].hidden = false
        dotViews[j].hidden = true
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

  private var strokeViews = [UIView]()
  private var dotViews = [UIView]()

  public override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    dotViews.forEach { (dot) in
      let width = CGRectGetWidth(dot.frame)
      dot.layer.cornerRadius = width / 2.0
      dot.clipsToBounds = true
    }
  }

}

// MARK: - UIKeyInput

extension PasswordInputView: UIKeyInput {

  public func insertText(text: String) {
    guard store.length + text.length <= digit else {
      return
    }
    store.appendContentsOf(text)
  }

  public func deleteBackward() {
    guard hasText() else {
      return
    }
    store.removeAtIndex(store.endIndex.predecessor())
  }

  public func hasText() -> Bool {
    return store.characters.count > 0
  }

  override public func canBecomeFirstResponder() -> Bool {
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

  private final func setup() {
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
      dot.hidden = true
      dotViews.append(dot)
      addSubview(dot)
    }

    // layout stroke
    var strokeDict = [String : AnyObject]()
    var strokeFormatString = ""
    strokeViews.enumerate().forEach { (index, stroke) in
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
      addConstraint(NSLayoutConstraint(item: stroke, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: stroke, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: CGFloat(strokeHeight)))
    }

    // horizontal
    let metrics = ["space": spacing]
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(strokeFormatString, options: .DirectionLeftToRight, metrics: metrics, views: strokeDict))

    // layout dot
    dotViews.enumerate().forEach { (index, dot) in
      let stroke = strokeViews[index]
      addConstraint(NSLayoutConstraint(item: dot, attribute: .CenterX, relatedBy: .Equal, toItem: stroke, attribute: .CenterX, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: dot, attribute: .CenterY, relatedBy: .Equal, toItem: stroke, attribute: .CenterY, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: dot, attribute: .Width, relatedBy: .Equal, toItem: stroke, attribute: .Width, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: dot, attribute: .Height, relatedBy: .Equal, toItem: dot, attribute: .Width, multiplier: 1, constant: 0))
    }
  }

}
