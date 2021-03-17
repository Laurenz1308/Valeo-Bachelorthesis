//
//  UserRepository.swift
//  Valeo
//
//  Created by Lori Hill on 11.02.21.
//

import Foundation
import Combine
import Firebase

/// Publisher for Userdata of Repository-Pattern.
/// All network requests for the user are performed by using this class.
final class UserRepository: ObservableObject {

    private let firestore = Firestore.firestore()
    
    @Published var user: User?
    @Published var mutableUserInformation: [UserMutable] = []
    @Published var authenticationError = false
    @Published var userId: String?
    @Published var noUserFound = false
    @Published var loading = false
    @Published var hasAcceptedPrivacyPolicy = false
    @Published var showSurvey = false
    @Published var surveyLink = ""
    
    init() {
        getUser()
        self.userId = getUserId()
        getMutableUserData()
        checkfcmToken()
        checkIfPrivacyPolicyIsAccepted()
        getSurveyLink()
    }
    
    private func getUserId() -> String? {
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            return nil
        }
        
        return id
    }
        
    func getUser() {
        
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            return
        }
        
        firestore
            .collection(FirestoreCollections.userCollection)
            .document(id)
            .addSnapshotListener { (snapshot, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                do {
                    self.user = try snapshot?.data(as: User.self)
                    
                    if self.user == nil {
                        self.noUserFound = true
                    }
                    
                } catch {
                    self.noUserFound = true
                    print(error)
                    return
                }
            }
    }
    
    func createUser(_ user: User) {
        self.loading = true
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            self.loading = false
            return
        }

        do {
            try firestore
                .collection(FirestoreCollections.userCollection)
                .document(id)
                .setData(from: user, completion: { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    self.noUserFound = false
                    DispatchQueue.main.async {
                        self.checkfcmToken()
                    }
                })
        } catch {
            print("Error on uploading created user")
            print(error.localizedDescription)
            self.loading = false
            return
        }
        self.loading = false
    }
    
    func getMutableUserData() {
        
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            return
        }
                        
        firestore
            .collection(FirestoreCollections.userCollection)
            .document(id)
            .collection(FirestoreCollections.userMutatingValues)
            .addSnapshotListener { (snapshot, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                self.mutableUserInformation = snapshot?.documents.compactMap {
                    try? $0.data(as: UserMutable.self)
                } ?? []
                
            }
    }
    
    func updateUser(_ user: User, _ mutableInformation: UserMutable) {
        
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            return
        }
        
        do {
            // Setting new userdata in firestore to user
            try firestore
                .collection(FirestoreCollections.userCollection)
                .document(id)
                .setData(from: user)
            
            // Check if mutating values collection already had a change on same day
            let existingDocRef = firestore
                .collection(FirestoreCollections.userCollection)
                .document(id)
                .collection(FirestoreCollections.userMutatingValues)
                .whereField(FirestoreCollections.userMutatingCreated, isEqualTo: mutableInformation.created)
            
            existingDocRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let snapshot = snapshot else {return}
                
                if snapshot.isEmpty{
                    // Create new Mutatingvalues Element
                    self.createUserMutable(mutableInformation)
                } else {
                    // modify first element
                    let docId = snapshot.documents[0].documentID
                    self.updateUserMutable(mutableInformation, docId: docId)
                }
                
            }
        } catch {
            print("Upload failed")
            return
        }
    }
    
    private func createUserMutable(_ mutableInformation: UserMutable) {
        
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            return
        }
        
        do {
            _ = try firestore
                .collection(FirestoreCollections.userCollection)
                .document(id)
                .collection(FirestoreCollections.userMutatingValues)
                .addDocument(from: mutableInformation)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    private func updateUserMutable(_ mutableInformation: UserMutable, docId: String) {
        
        guard let id = Auth.auth().currentUser?.uid else {
            print("User not authenticaed")
            self.authenticationError = true
            return
        }
        
        firestore
            .collection(FirestoreCollections.userCollection)
            .document(id)
            .collection(FirestoreCollections.userMutatingValues)
            .document(docId)
            .updateData([
                            "weight" : mutableInformation.weight,
                            "size" : mutableInformation.size,
                            "created" : mutableInformation.created,
                            "bmi" : mutableInformation.bmi,
                            "waist" : mutableInformation.waist ?? 0,
                            "bodyFat" : mutableInformation.bodyFat ?? 0,
                            "calorieGoal" : mutableInformation.calorieGoal],
                        completion: { (error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                        })
    }
    
    private func checkfcmToken() {
        
        let defaults = UserDefaults.standard

        let needToUploadToken = defaults.bool(forKey: "needToUploadFCMToken")
        
        if needToUploadToken {
            let token = defaults.string(forKey: "fcmToken")
            
            guard let existingToken = token, let uid = Auth.auth().currentUser?.uid else {
                print("No token found or not authenticated")
                return
            }
            
            firestore
                .collection("user")
                .document(uid)
                .setData(["fcmToken" : existingToken], merge: true) { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    print("fcmToken uploaded successfully")
                }
        } else {
            print("No need to upload token")
        }
    }
    
    private func checkIfPrivacyPolicyIsAccepted() {
        let defaults = UserDefaults.standard
        let hasAccepted = defaults.bool(forKey: "hasAcceptedPrivacyPolicy")
        self.hasAcceptedPrivacyPolicy = hasAccepted
    }
    
    // Checking if survey is available
    private func getSurveyLink() {
        let docRef = firestore
            .collection("Survey")
            .document("survey")
        
        docRef.getDocument { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let result = snapshot?.data() else {
                print("No data")
                return
            }
            guard let showSurvey = result["active"] as? Bool,
                  let link = result["link"] as? String else {
                print("Parsing data failed")
                return
            }
            self.showSurvey = showSurvey
            self.surveyLink = link
        }
    }
}
