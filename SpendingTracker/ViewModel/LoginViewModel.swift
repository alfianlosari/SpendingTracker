//
//  LoginViewModel.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import Combine
import CryptoKit

class LoginViewModel: NSObject, ObservableObject {
    
    @Published var loggedInUser: User?
    var auth = Auth.auth()
    
    fileprivate var currentNonce: String?
    
    override init() {
        loggedInUser = auth.currentUser
        super.init()
        
        auth.addStateDidChangeListener(authStateChanged(with:user:))
    }
    
    private func authStateChanged(with auth: Auth, user: User?) {
        guard user != self.loggedInUser else { return }
        self.loggedInUser = user
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
     private func randomNonceString(length: Int = 32) -> String {
       precondition(length > 0)
       let charset: Array<Character> =
           Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
       var result = ""
       var remainingLength = length

       while remainingLength > 0 {
         let randoms: [UInt8] = (0 ..< 16).map { _ in
           var random: UInt8 = 0
           let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
           if errorCode != errSecSuccess {
             fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
           }
           return random
         }

         randoms.forEach { random in
           if length == 0 {
             return
           }

           if random < charset.count {
             result.append(charset[Int(random)])
             remainingLength -= 1
           }
         }
       }

       return result
     }
    
    func login() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows[0]
    }
    
}

extension LoginViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.
            print(error.localizedDescription)
            return
          }
            
          // User is signed in to Firebase with Apple.
          // ...
        }
      }
    }
    

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }
    
    
}
