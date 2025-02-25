//
//  UserManager.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 12/2/24.
//

import Foundation
import FirebaseFirestore

//created DatabaseUser object as to not conflict with the User object in Authentication Manager
struct DatabaseUser {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let gender: String?
    let height: String?
    let exerciseLevel: String?
    let allergies: [String]?
    let weight: Double?
}

final class UserManager {
    
    //Instead of singletons in the future use Dependency Injection
    static let shared = UserManager()
    private init() { }
    
    //create new user in db
    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData: [String:Any] = [
            "user_id" : auth.uid,
            "is_anonymous" : auth.isAnonymous,
            "date_created" : Timestamp(),
        ]
        if let email = auth.email {
            userData["email"] = email
        }
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DatabaseUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let isAnonymous = data["is_anonymous"] as? Bool
        let email = data["email"] as? String
        let photoUrl = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        
        let gender = data["gender"] as? String
        let height = data["height"] as? String
        let exerciseLevel = data["exerciseLevel"] as? String
        let allergies = data["allergies"] as? [String]
        let weight = data["weight"] as? Double
        
        return DatabaseUser(
            userId: userId,
            isAnonymous: isAnonymous,
            email: email, photoUrl: photoUrl,
            dateCreated: dateCreated,
            gender: gender,
            height: height,
            exerciseLevel: exerciseLevel,
            allergies: allergies,
            weight: weight)
    }
}
