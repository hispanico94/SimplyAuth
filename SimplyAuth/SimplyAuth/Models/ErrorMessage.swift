//
//  ErrorMessage.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 15/11/2020.
//

struct ErrorMessage: Identifiable {
  let title = "Error"
  var message: String
  var id: String { message }
}
