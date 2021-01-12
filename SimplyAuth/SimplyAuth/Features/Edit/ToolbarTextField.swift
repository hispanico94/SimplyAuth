//
//  ToolbarTextField.swift
//  SimplyAuth
//
//  Created by Paolo Rocca on 12/01/21.
//

import SwiftUI

struct ToolbarTextField: UIViewRepresentable {
  var placeholder: String
  var keyboardType: UIKeyboardType
  @Binding var text: String
  
  func makeUIView(context: Context) -> UITextField {
    let textfield = UITextField()
    textfield.keyboardType = keyboardType
    textfield.placeholder = placeholder
    textfield.borderStyle = .roundedRect
    textfield.textAlignment = .right
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(textfield.doneButtonTapped(_:)))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.setItems([flexibleSpace, doneButton], animated: true)
    textfield.inputAccessoryView = toolBar
    return textfield
  }
  
  func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
  }
}

private extension  UITextField{
  @objc func doneButtonTapped(_ sender: UIBarButtonItem) -> Void {
    self.resignFirstResponder()
  }
}
