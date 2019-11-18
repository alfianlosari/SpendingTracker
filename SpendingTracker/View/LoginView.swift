//
//  LoginView.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    let action: () -> ()
    
    var body: some View {
        ZStack {
            LoginSplashImage()
            VStack(spacing: 32) {
                LogoTitle()
                SignInAppleButton {
                    self.action()
                }
                .frame(width: 130, height: 44)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView() {
            
        }
    }
}
