//
//  EditAction.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 21/10/2020.
//

import Foundation

enum EditAction {
  case issuerChanged(String)
  case accountChanged(String)
  case secretChanged(String)
  case passwordTypologyChanged(Password.Typology)
  case algorithmChanged(Algorithm)
  case digitsChanged(UInt8)
  case periodChanged(String)
  case counterChanged(String)
  
  case cancel
  case save
}
