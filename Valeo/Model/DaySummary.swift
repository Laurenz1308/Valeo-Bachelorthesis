//
//  DaySummary.swift
//  Valeo
//
//  Created by Lori Hill on 28.01.21.
//

import Foundation
import Firebase

/// Data struct of the summary of a users day with consumed nutrients.
struct DaySummary: Codable {
    
    let daySummaryId: UUID
    let userId: String
    
    var consumptions: [UUID]
    var activity: [UUID]
    
    var water: Double
    var anamnesisId: UUID?
    
    let date: String
    
    
    public static func loadFromFirestore() -> DaySummary {
        
        let todayISOString =
            ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withFullDate])
        
        var returnSummary = DaySummary(daySummaryId: UUID(), userId: Auth.auth().currentUser!.uid, consumptions: [], activity: [], water: 0, anamnesisId: nil, date: todayISOString)
        
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid
        
        let docRef = db.collection("daysummary")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: todayISOString)
        
        docRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                if snapshot != nil {
                    if !snapshot!.documents.isEmpty {
                        for document in snapshot!.documents {
                            do {
                                returnSummary = try document.data(as: DaySummary.self) ?? DaySummary(daySummaryId: UUID(),
                                                                                                     userId: "", consumptions: [],
                                                                                                     activity: [], water: 0,
                                                                                                     anamnesisId: nil,
                                                                                                     date: todayISOString)
                                return
                            } catch {
                                return
                            }
                        }
                    }
                }
            }
        }
        
        
        return returnSummary
    }
    
    public func saveToFirestore() {
        let db = Firestore.firestore()
        let docRef = db.collection("daysummary").document(daySummaryId.uuidString)
        
        do {
            try docRef.setData(from: self)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
