//
//  EditReducer.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 25/10/2020.
//

import ComposableArchitecture
import Foundation

let editReducer = Reducer<EditState, EditAction, Void> { state, action, _ in
  switch action {
  case .issuerChanged(let newIssuer):
    state.password.issuer = newIssuer
    return .none
  case .accountChanged(let newAccount):
    state.password.label = newAccount
    return .none
  case .secretChanged(let newSecret):
    state.password.secret = newSecret
    return .none
  case .passwordTypologyChanged(let newTypology):
    state.password.typology = newTypology
    return .none
  case .algorithmChanged(let newAlgorithm):
    state.password.algorithm = newAlgorithm
    return .none
  case .digitsChanged(let newDigits):
    state.password.digits = newDigits
    return .none
  case .periodChanged(let periodString):
    guard case .totp = state.password.typology else { return .none }
    guard let newPeriod = UInt64(periodString) else { return .none }
    state.password.typology = .totp(newPeriod)
    return .none
  case .counterChanged(let counterString):
    guard case .hotp = state.password.typology else { return .none }
    guard let newCounter = UInt64(counterString) else { return .none }
    state.password.typology = .hotp(newCounter)
    return .none
  case .save:
    return .none
  }
}
