//
//  HomeState.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 04/09/2020.
//

import Foundation

struct HomeState: Equatable {
  var passwords: [Password] = []
  var unixEpochSeconds: UInt = 0
}
