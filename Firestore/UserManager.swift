//
//  UserManager.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 2/3/25.
//

import Foundation
import FirebaseFirestore

    
struct DBUser: Codable {
    var userId: String
    var age: Int?
    var gender: String?
    var fitnessLevel: String?
    var goal: String?
    var weight: String?
    var height: String?
    var isAnonymous: Bool?
    var email: String?
    var photoUrl: String?
    var dateCreated: Date?
    var preferences: [String]?
    var profileImagePath: String?
    var profileImagePathUrl: String?
    var userInformation: [String]?

    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.preferences = nil
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
        self.userInformation = nil
        self.age = nil
        self.gender = nil
        self.fitnessLevel = nil
        self.goal = nil
        self.weight = nil
        self.height = nil
    }
    
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        preferences: [String]? = nil,
        profileImagePath: String? = nil,
        profileImagePathUrl: String? = nil,
        userInformation: [String]? = nil,
        age: Int? = nil,
        gender: String? = nil,
        fitnessLevel: String? = nil,
        goal: String? = nil,
        weight: String? = nil,
        height: String? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.preferences = preferences
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
        self.userInformation = userInformation
        self.age = age
        self.gender = gender
        self.fitnessLevel = fitnessLevel
        self.goal = goal
        self.weight = weight
        self.height = height
    }
    

    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case preferences = "preferences"
        case profileImagePath = "profile_image_path"
        case profileImagePathUrl = "profile_image_path_url"
        case userInformation = "userInformation"
        case age = "age"
        case gender = "gender"
        case fitnessLevel = "fitness_level"
        case goal = "goal"
        case weight = "weight"
        case height = "height"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)
        self.userInformation = try container.decodeIfPresent([String].self, forKey: .userInformation)
        self.age = try container.decodeIfPresent(Int.self, forKey: .age)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.fitnessLevel = try container.decodeIfPresent(String.self, forKey: .fitnessLevel)
        self.goal = try container.decodeIfPresent(String.self, forKey: .goal)
        self.weight = try container.decodeIfPresent(String.self, forKey: .weight)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)
        try container.encodeIfPresent(self.userInformation, forKey: .userInformation)
        try container.encodeIfPresent(self.age, forKey: .age)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.fitnessLevel, forKey: .fitnessLevel)
        try container.encodeIfPresent(self.goal, forKey: .goal)
        try container.encodeIfPresent(self.weight, forKey: .weight)
        try container.encodeIfPresent(self.height, forKey: .height)
    }
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userFavoriteProductCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favorite_products")
    }
    
    private func userFavoriteProductDocument(userId: String, favoriteProductId: String) -> DocumentReference {
        userFavoriteProductCollection(userId: userId).document(favoriteProductId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private var userFavoriteProductsListener: ListenerRegistration? = nil
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//
//        return DBUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserProfile(user: DBUser) async throws {
        var data: [String: Any] = [:]
        
        if let weight = user.weight {
            data["weight"] = weight
        }
        
        if let height = user.height {
            data["height"] = height
        }
        
        if let gender = user.gender {
            data["gender"] = gender
        }
        
        if let age = user.age {
            data["age"] = age
        }
        
        if let fitnessLevel = user.fitnessLevel {
            data["fitness_level"] = fitnessLevel
        }
        
        if let goal = user.goal {
            data["goal"] = goal
        }
        
        try await userDocument(userId: user.userId).updateData(data)
        
    }
    
    func addUserInformation(userId: String, userInformation: String) async throws {
        var data: [String:Any] = [
            DBUser.CodingKeys.userInformation.rawValue : FieldValue.arrayUnion([userInformation])
        ]
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    
    func addUserFavoriteProduct(userId: String, productId: Int) async throws {
        let document = userFavoriteProductCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            UserFavoriteProduct.CodingKeys.id.rawValue : documentId,
            UserFavoriteProduct.CodingKeys.productId.rawValue : productId,
            UserFavoriteProduct.CodingKeys.dateCreated.rawValue : Timestamp()
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func removeUserFavoriteProduct(userId: String, favoriteProductId: String) async throws {
        try await userFavoriteProductDocument(userId: userId, favoriteProductId: favoriteProductId).delete()
    }
    
    //func getAllUserFavoriteProducts(userId: String) async throws -> [UserFavoriteProduct] {
        //try await userFavoriteProductCollection(userId: userId).getDocuments(as: UserFavoriteProduct.self)
    //}
    
    func removeListenerForAllUserFavoriteProducts() {
        self.userFavoriteProductsListener?.remove()
    }
    
    func addListenerForAllUserFavoriteProducts(userId: String, completion: @escaping (_ products: [UserFavoriteProduct]) -> Void) {
        self.userFavoriteProductsListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self) })
            completion(products)
            
            querySnapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New products: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    print("Modified products: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removed products: \(diff.document.data())")
                }
            }
        }
    }
    
//    func addListenerForAllUserFavoriteProducts(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
//        let publisher = PassthroughSubject<[UserFavoriteProduct], Error>()
//
//        self.userFavoriteProductsListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self) })
//            publisher.send(products)
//        }
//
//        return publisher.eraseToAnyPublisher()
//    }
    //func addListenerForAllUserFavoriteProducts(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
        //let (publisher, listener) = userFavoriteProductCollection(userId: userId)
            //.addSnapshotListener(as: UserFavoriteProduct.self)
        
        //self.userFavoriteProductsListener = listener
        //return publisher
    //}
    
}
import Combine

struct UserFavoriteProduct: Codable {
    let id: String
    let productId: Int
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.productId = try container.decode(Int.self, forKey: .productId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.productId, forKey: .productId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
}
