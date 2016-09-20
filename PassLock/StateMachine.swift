//
//  StateMachine.swift
//  PassLockDemo
//
//  Created by edison on 9/20/16.
//  Copyright © 2016 NSCodeMonkey. All rights reserved.
//

import Foundation

public class StateMachine<State, Event> {
  public typealias TransitionCallback = (State, Event, State) -> Void
  public typealias TransitionLogic = (State, Event) -> (State, TransitionCallback?)?
  
  public let initialState: State
  public private(set) var state: State
  public let transitionLogic: TransitionLogic?
  
  public init(initialState: State, transitionLogic: TransitionLogic?) {
    self.initialState = initialState
    self.state = initialState
    self.transitionLogic = transitionLogic
  }
}

extension StateMachine {
  public func handleEvent(event: Event) {
    guard let (newState, callback) = transitionLogic?(state, event) else {
      return
    }
    
    let oldState = state
    state = newState
    callback?(oldState, event, newState)
  }
}