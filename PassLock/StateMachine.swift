//
//  StateMachine.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation

open class StateMachine<State, Event, Info> {
  public typealias TransitionCallback = (State, Event, Info?) -> Void
  public typealias TransitionLogic = (State, Event) -> (State, TransitionCallback?)?

  open let initialState: State
  open fileprivate(set) var state: State
  open let transitionLogic: TransitionLogic?

  public init(initialState: State, transitionLogic: TransitionLogic?) {
    self.initialState = initialState
    self.state = initialState
    self.transitionLogic = transitionLogic
  }
}

extension StateMachine {
  public func handleEvent(_ event: Event, info: Info?) {
    guard let (newState, callback) = transitionLogic?(state, event) else {
      return
    }

    let oldState = state
    state = newState
    callback?(oldState, event, info)
  }
}
