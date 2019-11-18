//
//  SignInAppleButton.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import SwiftUI
import AuthenticationServices

struct SignInAppleButton: UIViewRepresentable {
    func makeCoordinator() -> SignInAppleButton.Coordinator {
        Coordinator(action: self.action)
    }

    let action: () -> ()
    
    func makeUIView(context: UIViewRepresentableContext<SignInAppleButton>) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: UIViewRepresentableContext<SignInAppleButton>) {
        uiView.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped(_:)), for: .touchUpInside)
    }
    
    
    class Coordinator {
        
        let action: () -> ()
        
        init(action: @escaping() -> ()) {
            self.action = action
        }
        
        @objc fileprivate func buttonTapped(_ sender: Any) {
            action()
        }
        
        
    }
    
  
}
