//
//  DaysummaryRepository.swift
//  Valeo
//
//  Created by Lori Hill on 13.02.21.
//

import Foundation
import Firebase

/// Manages the Firebase data flow of all data related to a daysummary.
final class DaysummaryRepository: ObservableObject {
    
    @Published var daySummary: DaySummary?
    @Published var todaysConsumptions: [Consumption] = []
    
    @Published var oldDaysummary: DaySummary?
    @Published var oldConsumptions: [Consumption] = []
    
    @Published var loading = false
    
    private let firestore = Firestore.firestore()
    
    init() {
        getTodaysDaySummary()
        getTodaysConsumption()
    }
    
    func addConsumption(_ consumption: Consumption) {
        
        // first upload new consumption in consumptions
        let consumptionDocRef = firestore
            .collection(FirestoreCollections.consumptionCollection)
            .document(consumption.consumptionId.uuidString)
        
        do {
            try consumptionDocRef.setData(from: consumption)
            self.daySummary?.consumptions.append(consumption.consumptionId)
            uploadSummaryToFirebase()
        } catch {
            print("Decoding consumption failed")
            return
        }
    }
    
    func createAnamnesis(_ anamnesis: Anamnesis) {
        
        guard let daysummary = self.daySummary else {
            print("No current daysummary")
            return
        }
        
        // Upload anamnesis to Firestore
        let anamnesisDocRef = firestore
            .collection(FirestoreCollections.anamnesisCollection)
            .document(anamnesis.anamnesisId.uuidString)
        
        do {
            try anamnesisDocRef.setData(from: anamnesis, completion: { (error) in
                if error != nil {
                    print("Anamnesis upload error")
                }
                
                var modifiedSummary = daysummary
                modifiedSummary.anamnesisId = anamnesis.anamnesisId
                
                let summaryDocRef = self.firestore
                    .collection(FirestoreCollections.daysummaryCollection)
                    .document(daysummary.daySummaryId.uuidString)
                
                do {
                    try summaryDocRef.setData(from: modifiedSummary, completion: { (error) in
                        if error != nil {
                            print("Upload of new daysummary failed")
                        }
                        return
                    })
                } catch {
                    print(error.localizedDescription)
                    print("Decoding new daysummary failed")
                    return
                }
                
                
            })
        } catch {
            print(error.localizedDescription)
            print("Decoding of anamnesis failed")
            return
        }
        
        // On success of upload add anamnesisid to daysummary and upload daysummary
    }
    
    func deleteConsumption(by id: UUID) {
        
        guard let daysummary = self.daySummary else {
            return
        }
        
        var modifiedSummary = daysummary
        modifiedSummary.consumptions.removeAll(where: { (uuid) -> Bool in
            uuid == id
        })
        
        let docRef = firestore
            .collection(FirestoreCollections.daysummaryCollection)
            .document(daysummary.daySummaryId.uuidString)
        
        do {
            try docRef.setData(from: modifiedSummary)
        } catch {
            print(error.localizedDescription)
            return
        }
        
    }
    
    /// Upload a changed daysummary to Firebase
    func uploadSummaryToFirebase() {
        
        guard self.daySummary != nil else {
            print("No current daysummary found.")
            return
        }
        
        let docRef = firestore
            .collection(FirestoreCollections.daysummaryCollection)
            .document(daySummary!.daySummaryId.uuidString)
        
        do {
            try docRef.setData(from: self.daySummary)
        } catch {
            // MARK: Error handling required
            print(error.localizedDescription)
        }
    }
    
    /// Get a daysummary from Firestore if there exists one
    /// In case there is no match found create a new Daysummary
    private func getTodaysDaySummary() {
        guard let uid = Auth.auth().currentUser?.uid else {
            // MARK: Authenticationerror
            print("User not authenticated")
            return
        }
        
        let today = ISO8601DateFormatter.string(from: Date(),
                                                timeZone: TimeZone.current,
                                                formatOptions: [.withFullDate])
        
        let newDaySummary = DaySummary(daySummaryId: UUID(),
                                       userId: uid,
                                       consumptions: [],
                                       activity: [],
                                       water: 0,
                                       anamnesisId: nil,
                                       date: today)
        
        let docRef = firestore
            .collection(FirestoreCollections.daysummaryCollection)
            .whereField(FirestoreCollections.daysummaryUserId, isEqualTo: uid)
            .whereField(FirestoreCollections.daysummaryDate, isEqualTo: today)
        
        self.loading = true
        
        docRef.addSnapshotListener { (snapshot, error) in
            if error != nil {
                // MARK: Usefull error handling required
                print(error!.localizedDescription)
                self.loading = false
                return
            }
            
            guard let snapshot = snapshot else {
                // MARK: Usefull error handling required
                print("Snapshot is nil")
                self.loading = false
                return
            }
            
            if !snapshot.isEmpty && snapshot.documents.count > 0 {
                // If there are documents the first must be the required doc
                do {
                    // Decode data to daysummary
                    let decoded = try snapshot.documents[0].data(as: DaySummary.self)
                    
                    self.daySummary = decoded
                    self.loading = false
                    return
                } catch {
                    // Decoding failed
                    // MARK: Error handling required
                    print("Decoding failed")
                    self.loading = false
                    return
                }
            } else {
                // No daysummary found -> new daysummary required
                self.daySummary = newDaySummary
                self.loading = false
            }
        }
    }
    
    /// Get all consumptons of current day
    private func getTodaysConsumption() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            // MARK: Error handling required
            return
        }
        
        let todayISOString =
            ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withFullDate])
        
        let docRef = firestore
            .collection(FirestoreCollections.consumptionCollection)
            .whereField(FirestoreCollections.consumptionUserId, isEqualTo: uid)
            .whereField(FirestoreCollections.consumptionCreated, isGreaterThanOrEqualTo: todayISOString)
        self.loading = true
        docRef.addSnapshotListener { (snapshot, error) in
            if error != nil {
                // MARK: Error handling
                self.loading = false
                return
            }
            
            guard let snapshot = snapshot else {
                // MARK: Error handling
                self.loading = false
                return
            }
            
            do {
                self.todaysConsumptions = try snapshot.documents.compactMap {
                    try $0.data(as: Consumption.self)
                }
                self.loading = false
            } catch {
                print(error.localizedDescription)
                self.loading = false
                return
            }
            
        }
    }
    
    /// Get a daysummary of an oldDay
    func getOldDaySummary(of day: Date) {
        guard let uid = Auth.auth().currentUser?.uid else {
            // MARK: Authenticationerror
            print("User not authenticated")
            return
        }
        
        let dayString = ISO8601DateFormatter.string(from: day,
                                                timeZone: TimeZone.current,
                                                formatOptions: [.withFullDate])
        
        let docRef = firestore
            .collection(FirestoreCollections.daysummaryCollection)
            .whereField(FirestoreCollections.daysummaryUserId, isEqualTo: uid)
            .whereField(FirestoreCollections.daysummaryDate, isEqualTo: dayString)
            .limit(to: 1)
        
        self.loading = true
        docRef.getDocuments { (snapshot, error) in
            if error != nil {
                // MARK: Usefull error handling required
                print(error!.localizedDescription)
                self.loading = false
                return
            }
            
            guard let snapshot = snapshot else {
                // MARK: Usefull error handling required
                print("Snapshot is nil")
                self.loading = false
                return
            }
            
            if !snapshot.isEmpty && snapshot.documents.count > 0 {
                // If there are documents the first must be the required doc
                do {
                    // Decode data to daysummary
                    let decoded = try snapshot.documents[0].data(as: DaySummary.self)
                    
                    self.oldDaysummary = decoded
                    self.loading = false
                    return
                } catch {
                    // Decoding failed
                    // MARK: Error handling required
                    print("Decoding failed")
                    self.loading = false
                    return
                }
            } else {
                // No daysummary found -> new daysummary required
                self.oldDaysummary = nil
                self.loading = false
            }
        }
        
       
    }
    
    /// Get all consumptions of old day
    func getOldConsumption(of day: Date) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            // MARK: Error handling required
            return
        }
        
        let dayString =
            ISO8601DateFormatter.string(from: day, timeZone: TimeZone.current, formatOptions: [.withFullDate])
        let nextDay = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: day)
        
        guard let nextDaySave = nextDay else {
            print("Could not get nexDay for loading old day")
            return
        }
        
        let nextDayString =
            ISO8601DateFormatter.string(from: nextDaySave, timeZone: TimeZone.current, formatOptions: [.withFullDate])
        
        let docRef = firestore
            .collection(FirestoreCollections.consumptionCollection)
            .whereField(FirestoreCollections.consumptionUserId, isEqualTo: uid)
            .whereField(FirestoreCollections.consumptionCreated, isGreaterThanOrEqualTo: dayString)
            .whereField(FirestoreCollections.consumptionCreated, isLessThan: nextDayString)
        self.loading = true
        docRef.getDocuments { (snapshot, error) in
            if error != nil {
                // MARK: Error handling
                self.loading = false
                return
            }
            
            guard let snapshot = snapshot else {
                // MARK: Error handling
                self.loading = false
                return
            }
            
            do {
                self.oldConsumptions = try snapshot.documents.compactMap {
                    try $0.data(as: Consumption.self)
                }
                self.loading = false
            } catch {
                print(error.localizedDescription)
                self.loading = false
                self.oldConsumptions = []
                return
            }
            
        }
    }
}
