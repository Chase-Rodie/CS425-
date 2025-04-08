//
//  UserManager.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 2/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct DBUser: Identifiable, Codable, Equatable {
    var userId: String
    var name: String?
    var age: Int?
    var gender: String?
    var fitnessLevel: String?
    var goal: String?
    var height: String?
    var weight: String?
    var weightHistory: [(date: Date, weight: String)]?
    var isAnonymous: Bool?
    var email: String?
    var photoUrl: String?
    var dateCreated: Date?
    var preferences: [String]?
    var profileImagePath: String?
    var profileImagePathUrl: String?
    var userInformation: [String]?
    
    var id: String {
        return userId
    }
    
    static func ==(lhs: DBUser, rhs: DBUser) -> Bool {
        return lhs.userId == rhs.userId &&
        lhs.name == rhs.name &&
        lhs.age == rhs.age &&
        lhs.gender == rhs.gender &&
        lhs.fitnessLevel == rhs.fitnessLevel &&
        lhs.goal == rhs.goal &&
        lhs.height == rhs.height &&
        lhs.weight == rhs.weight &&
        lhs.isAnonymous == rhs.isAnonymous &&
        lhs.email == rhs.email &&
        lhs.photoUrl == rhs.photoUrl &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.preferences == rhs.preferences &&
        lhs.profileImagePath == rhs.profileImagePath &&
        lhs.profileImagePathUrl == rhs.profileImagePathUrl &&
        lhs.userInformation == rhs.userInformation
    }

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
        height: String? = nil,
        weightHistory: [(date: Date, weight: String)]? = nil,
        name: String? = nil
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
        self.weightHistory = weightHistory
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case isAnonymous = "isAnonymous"
        case email = "email"
        case photoUrl = "photoUrl"
        case dateCreated = "dateCreated"
        case preferences = "preferences"
        case profileImagePath = "profileImagePath"
        case profileImagePathUrl = "profileImagePathUrl"
        case userInformation = "userInformation"
        case age = "age"
        case gender = "gender"
        case fitnessLevel = "fitnessLevel"
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

@MainActor
final class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var currentUser: DBUser?

    private let db = Firestore.firestore()

    private init() {
        Task {
            await fetchCurrentUser()
        }
    }

    private let userCollection: CollectionReference = Firestore.firestore().collection("users")

    private func userDocument(userId: String) -> DocumentReference {
        return userCollection
            .document(userId)
            .collection("UserInformation")
            .document("profile")
    }


    private func userFavoriteProductCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favorite_products")
    }

    func loadUserProfile(userId: String) async throws -> DBUser? {
        let user = try await UserManager.shared.getUser(userId: userId)
        return user
    }

    func createNewUser(user: DBUser) async throws {
        do {
            try userDocument(userId: user.userId).setData(from: user, merge: false)
            print("User successfully created in Firestore")
        } catch {
            print("Error creating user in Firestore: \(error)")
        }
    }

    private func userFavoriteProductDocument(userId: String, favoriteProductId: String) -> DocumentReference {
        userFavoriteProductCollection(userId: userId).document(favoriteProductId)
    }

    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()

    
    func getUser(userId: String) async throws -> DBUser {
        let profileRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("UserInformation")
            .document("profile")

        let snapshot = try await profileRef.getDocument()

        guard var data = snapshot.data() else {
            print("No user data found in Firestore for userId: \(userId)")
            throw NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        print("📡 Firestore raw data: \(data)")

        data["userId"] = userId

        if let timestamp = data["dateCreated"] as? Timestamp {
            data["dateCreated"] = timestamp.dateValue()
        }

        if let dateCreated = data["dateCreated"] as? Date {
            data["dateCreated"] = dateCreated.timeIntervalSince1970
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let user = try JSONDecoder().decode(DBUser.self, from: jsonData)
            print("Successfully decoded user: \(user)")
            return user
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }



    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
        ]

        try await userDocument(userId: userId).updateData(data)
    }

    func updateUserProfile(user: DBUser) async throws {
        let userRef = db.collection("users")
                        .document(user.userId)
                        .collection("UserInformation")
                        .document("profile")
        
        let userData: [String: Any] = [
            "userId": user.userId,
            "name": user.name ?? "",
            "age": user.age ?? 0,
            "gender": user.gender ?? "",
            "fitnessLevel": user.fitnessLevel ?? "",
            "goal": user.goal ?? "",
            "height": user.height ?? "",
            "weight": user.weight ?? "",
            "email": user.email ?? "",
            "dateCreated": user.dateCreated != nil ? Timestamp(date: user.dateCreated!) : FieldValue.serverTimestamp()
        ]
        print("User data thats updated: \(userData)")
        try await userRef.setData(userData, merge: true)
        print("Data updated")
    }


    func addUserInformation(userId: String, userInformation: String) async throws {
        var data: [String:Any] = [
            DBUser.CodingKeys.userInformation.rawValue : FieldValue.arrayUnion([userInformation])
        ]
        try await userDocument(userId: userId).updateData(data) x
    }

    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]

        try await userDocument(userId: userId).updateData(data)
    }

    @MainActor
    func fetchCurrentUser() async {
        print("📡 Attempting to fetch current user...")

        guard let userId = Auth.auth().currentUser?.uid else {
            print("No Firebase user ID found")
            return
        }

        print("Firebase User ID: \(userId)")

        do {
            let user = try await getUser(userId: userId)
            DispatchQueue.main.async {
                self.currentUser = user
                print("Successfully fetched user: \(user)")
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
}
