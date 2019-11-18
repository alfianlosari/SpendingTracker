//
//  ContentView.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            if loginViewModel.loggedInUser != nil {
                LogListView()
                    .animation(.linear)
                    .transition(.move(edge: .bottom))
            } else {
                LoginView {
                    self.loginViewModel.login()
                }
                .animation(.linear)
                .transition(.move(edge: .bottom))
            }
        }
    }
}



struct HomeView: View {
    
    var body: some View {
        Text("Home View")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoginSplashImage: View {
    var body: some View {
        Image("login")
            .resizable()
            .aspectRatio(1/1, contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .blur(radius: 3)
    }
}

struct LogoTitle: View {
    var body: some View {
        HStack {
            
            Image(systemName: "dollarsign.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            
            
            VStack(spacing: 8) {
                Text("Spending Tracker")
                    .font(.custom("SF Pro Display", size: 38))
                    .lineLimit(2)
                    .foregroundColor(.white)
                
                Text("Built with Firestore DB & Firebase Auth")
                    .font(.headline)
                    .foregroundColor(.white)
                
            }
            
            
            
            
        }
    }
}

