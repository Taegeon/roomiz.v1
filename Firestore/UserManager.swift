//
//  UserManager.swift
//  roomiz
//
//  Created by Taegeon Lee on 3/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser : Codable{
    let userId: String
    let email : String?
    let photoUrl :String?
    let dateCreated : Date?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
    }
    
    init (
        userId : String,
        email : String? = nil,
        photoUrl : String? = nil,
        dateCreated: Date? = nil,
        profileImagePath : String? = nil,
        profileImagePathUrl : String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
    }
    
    
    enum CodingKeys: String, CodingKey {
           case userId = "user_id"
           case email = "email"
           case photoUrl = "photo_url"
           case dateCreated = "date_created"
           case profileImagePath = "profile_image_path"
           case profileImagePathUrl = "profile_image_path_url"
       }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)
    }
    
}



final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    

    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    
    
    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func createNewUser(user: DBUser)  async throws{
        try userDocument(userId: user.userId).setData(from: user, merge: false)
//        var userData: [String: Any] = [
//            "user_id" : auth.uid,
//            "date_created" : Timestamp(),
//        ]
//        
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)

//        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
    }
    
}
