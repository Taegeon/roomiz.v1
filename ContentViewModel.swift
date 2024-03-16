//
//  FirestoreManager.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/15/24.
//

import Foundation
import Firebase

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    func saveImageData(imageData: ImageDataModel) {
        do {
            let _ = try db.collection("images").addDocument(from: imageData)
        } catch let error {
            print("Error saving image data: \(error.localizedDescription)")
        }
    }
    
    func saveLikesData(likesData: LikesModel) {
        do {
            let documentRef = db.collection("likes").document(likesData.title)
            try documentRef.setData(from: likesData)
        } catch let error {
            print("Error saving likes data: \(error.localizedDescription)")
        }
    }
    
    func getLikesData(completion: @escaping ([LikesModel]) -> Void) {
        db.collection("likes").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting likes data: \(error.localizedDescription)")
                completion([])
            } else if let snapshot = snapshot {
                let likesData = snapshot.documents.compactMap { document -> LikesModel? in
                    do {
                        let likesData = try document.data(as: LikesModel.self)
                        return likesData
                    } catch {
                        print("Error decoding likes data: \(error.localizedDescription)")
                        return nil
                    }
                }
                completion(likesData)
            }
        }
    }
    
}
