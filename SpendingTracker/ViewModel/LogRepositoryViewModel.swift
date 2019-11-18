//
//  LogRepositoryViewModel.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 11/18/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Firebase
import Foundation
import SwiftUI

class LogRepositoryViewModel: ObservableObject {
    
    @Published var logs = [SpendingLog]()
    
    private let logsCollection = Firestore.firestore().collection("logs")
    private var listenerToken: ListenerRegistration?
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
        
    func add(log: SpendingLog) {
        guard let userId = self.userId else { return }
        
        logsCollection.document(log.id).setData([
            "name": log.name,
            "amount": log.amount,
            "category": log.category.rawValue,
            "date": log.date,
            "userId": userId
        ])
    }
    
    func update(log: SpendingLog) {
        guard let userId = self.userId else { return }

        logsCollection.document(log.id).updateData([
            "name": log.name,
            "amount": log.amount,
            "category": log.category.rawValue,
            "date": log.date,
            "userId": userId
        ])
    }
    
    func delete(log: SpendingLog) {
        guard let _ = self.userId else { return }
        
        logsCollection.document(log.id).delete()
    }
    
    func observeLogs(selectedFilters: Set<Category>, selectedSortOrder: SortOrder, selectedSortFilter: SortFilter) {
        removeListener()
        
        guard let userId = self.userId else { return }
        
        var query = logsCollection.whereField("userId", isEqualTo: userId)
        if selectedFilters.count > 0 {
            let filters = selectedFilters.map { $0.rawValue }
            query = query
                .whereField("category", in: filters)
        }
        
        self.listenerToken = query
            .order(by: selectedSortFilter.rawValue, descending: selectedSortOrder == .descending ? true : false)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let snapshot = snapshot else { return }
                
                for document in snapshot.documentChanges {
                    let log = SpendingLog(id: document.document.reference.documentID, dictionary: document.document.data())

                    switch document.type {
                    case .added:
                        self.logs.insert(log, at: Int(document.newIndex))
                        
                    case .modified:
                        self.logs.remove(at: Int(document.oldIndex))
                        self.logs.insert(log, at: Int(document.newIndex))
                                 
                    case .removed:
                        self.logs.remove(at: Int(document.oldIndex))
                    }
                    
                }
                
            })
            
            
//            .addSnapshotListener { (snapshot, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//                guard let snapshot = snapshot else { return }
//                self.logs = snapshot.documents.map { SpendingLog(id: $0.reference.documentID, dictionary: $0.data()) }
//        }
    }
    
    func removeListener() {
        listenerToken?.remove()
        listenerToken = nil
        
        self.logs.removeAll()
    }
    
    deinit {
        removeListener()
    }
        
}

extension SpendingLog {
    
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.amount = dictionary["amount"] as? Double ?? 0
        if let categoryText = dictionary["category"] as? String,
            let category = Category(rawValue: categoryText.lowercased()) {
            self.category = category
        } else {
            self.category = .personal
        }
        
        if let timestamp = dictionary["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
    }
    
    
}
