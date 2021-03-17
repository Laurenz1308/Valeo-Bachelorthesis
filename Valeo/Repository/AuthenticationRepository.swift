//
//  AuthenticationRepository.swift
//  Valeo
//
//  Created by Lori Hill on 12.02.21.
//

import Foundation
import Combine
import Firebase

/// Handles the authentication process in login.
final class AuthenticationRepository: ObservableObject {
    // For Alerts
    @Published var alert = false
    @Published var alertMessage = ""
        
    // LoadingScreen
    @Published var isLoading = false
    
    @Published var loggedIn: Bool
    
    @Published var firebaseUser: Firebase.User?
        
    init() {
        if Auth.auth().currentUser != nil {
            self.loggedIn = true
            getUserFromFirebaseAuth()
        } else {
            self.loggedIn = false
        }
    }
    
    /// Login of a user to Firebase. After execution self.loggedIn will indicate weather the process succeeded or failed.
    ///  - parameters email: email if the user
    ///  - parameters password: password of the user
    func loginWithMailAndPassword(email: String, password: String) {
        self.isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.loggedIn = false
                self.isLoading = false
                self.alertMessage = "Login failed"
                self.alert = true
                return
            }
            self.loggedIn = true
            self.isLoading = false
            self.firebaseUser = result?.user
        }
    }
    
    /// Signs a new user up to Firebase. After execution self.loggedIn will indicate weather the process succeeded or failed.
    ///  - parameters email: the mailadress used by the user
    ///  - parameters password: the users password
    func signUpWithMailAndPassword(email: String, password: String) {
        self.isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.loggedIn = false
                self.isLoading = false
                self.alertMessage = "Login failed"
                self.alert = true
                return
            }
            self.loggedIn = true
            self.isLoading = false
            self.firebaseUser = result?.user
        }
    }
    
    /// Sign in with anonymized Apple authentication technique into Firebase.
    /// - parameters tokenString: a string of a token from apple services needed for sign in
    func signInWithApple(tokenString: String, nonce: String) {
        self.isLoading = true
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: tokenString,
                                                          rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
            self.isLoading = false
            if error != nil {
                self.alertMessage = "Firebase rejected sign in with Apple"
                self.alert = true
                self.loggedIn = false
                print(error!.localizedDescription)
                return
            }
            
            self.loggedIn = true
            self.firebaseUser = authResult?.user
        }
        
        
    }
    
    /// Sign in anonymoulsy without creating an account in Firebase. In case of success received user will be stored in defaults.
    func anonymousLogin() {
        self.isLoading = true
        Auth.auth().signInAnonymously { (result, error) in
            self.isLoading = false
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            self.loggedIn = true
            self.firebaseUser = result?.user
        }
    }
    
    /// Logout the user from Firebase.
    func logout() {
        
        let defaults = UserDefaults.init()
        
        do {
            try Auth.auth().signOut()
            
            defaults.set(false, forKey: "status")
            defaults.setValue(false, forKey: "showedIntroduction")
            self.loggedIn = false
            self.firebaseUser = nil
                        
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Delete a user from Firebase
    func deleteUser() {
        guard let user = Auth.auth().currentUser else {
            print("No user found")
            self.loggedIn = false
            return
        }
        user.delete { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            print("Account deleted")
            self.loggedIn = false
            self.firebaseUser = nil
            return
        }
    }
    
    func getUserFromFirebaseAuth() {
        if let user = Auth.auth().currentUser {
            self.firebaseUser = user
        }
    }
}
