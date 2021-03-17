//
//  AuthenticationViewModel.swift
//  Valeo
//
//  Created by Lori Hill on 12.02.21.
//

import Foundation
import Combine
import CryptoKit
import AuthenticationServices
import Firebase

final class AuthenticationViewModel: ObservableObject {
    
    private var authenticationRepository = AuthenticationRepository()
    
    // Login variables
    @Published var email = ""
    @Published var password = ""
    
    // SignUp Variables
    @Published var newMail = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    //Sign in with Apple
    @Published var nonce = ""
    
    // For Alerts
    @Published var alert = false
    @Published var alertMessage = ""
    
    // LoadingScreen
    @Published var isLoading = false
    
    // States for App
    @Published var loggedIn = false
    @Published var firebaseUser: Firebase.User?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let signInWithAppleErrorMessage = "Sign in with Apple failed"
    
    init() {
        authenticationRepository.$loggedIn
            .assign(to: \.loggedIn, on: self)
            .store(in: &cancellables)
        
        authenticationRepository.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        authenticationRepository.$alert
            .assign(to: \.alert, on: self)
            .store(in: &cancellables)
        
        authenticationRepository.$alertMessage
            .assign(to: \.alertMessage, on: self)
            .store(in: &cancellables)
        
        authenticationRepository.$firebaseUser
            .assign(to: \.firebaseUser, on: self)
            .store(in: &cancellables)
    }
    
    /// Handeling the login from UI and passing the process to the repository
    func login() {
        
        if checkMailRegex(of: self.email) {
            authenticationRepository
                .loginWithMailAndPassword(email: self.email, password: self.password)
        } else {
            self.alertMessage = "Mail does not conform to regular mail pattern"
            self.alert = true
        }
    }
    
    /// Handeling the signupdata from the UI and passing the request to the repository.
    func signUp() {
        if checkMailRegex(of: self.newMail) && self.newPassword == self.confirmPassword {
            authenticationRepository
                .signUpWithMailAndPassword(email: self.newMail, password: self.newPassword)
        } else {
            self.alertMessage = "Invalid mail or not matching passwords"
            self.alert = true
        }
    }
    
    /// Handeling the token of the request and passing it to the repository.
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        
        // getting token
        guard let token = credential.identityToken else {
            alertMessage = signInWithAppleErrorMessage
            alert = true
            return
        }
        
        // Token string
        guard let tokenString = String(data: token, encoding: .utf8) else {
            alertMessage = signInWithAppleErrorMessage
            alert = true
            return
        }
        
        self.authenticationRepository.signInWithApple(tokenString: tokenString,
                                                      nonce: self.nonce)
        
    }
    
    /// Sign in Anonymously in the repository
    func signInAnonymously() {
        self.authenticationRepository.anonymousLogin()
    }
    
    func logout() {
        authenticationRepository.logout()
    }
    
    func deleteAccount() {
        self.authenticationRepository.deleteUser()
    }
    
    // Regex check for mail and password
    // Mail needs to be a valid mail and password to fullfill irebase requirements
    func checkMailAndPasswordRequirements() -> Bool {
                
        // Email test
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
            
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self.newMail as NSString
            let results = regex.matches(in: self.newMail, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                return false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
        
        
        
        
        return true
        
    }
    
    
    private func checkMailRegex(of mail: String) -> Bool {
        
        // Mail RegEx
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = mail as NSString
            let results = regex.matches(in: mail, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                return false
            }
            return true
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    func randomNonceString(length: Int = 32) -> String {
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
          if remainingLength == 0 {
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
    
    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
