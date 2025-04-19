//
//  AuthenticationManager.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

//A lot of code was grabbed from Firebase's documentation on how to support Authentication
//https://firebase.google.com/docs/auth/ios/password-auth

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    let isEmailVerified: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
        self.isEmailVerified = user.isEmailVerified
    }
}

func unlinkProvider(_ provider: AuthProviderOption) async throws {
    guard let user = Auth.auth().currentUser else {
        throw CustomAuthenticationErrors.userNotFound
    }
    do {
        try await user.unlink(fromProvider: provider.rawValue)
    } catch {
        throw CustomAuthenticationErrors.unknownError(error.localizedDescription)
    }
}

func updateUserProfile(displayName: String?, photoUrl: URL?) async throws {
    guard let user = Auth.auth().currentUser else {
        throw CustomAuthenticationErrors.userNotFound
    }
    let changeRequest = user.createProfileChangeRequest()
    changeRequest.displayName = displayName
    changeRequest.photoURL = photoUrl
    do {
        try await changeRequest.commitChanges()
    } catch {
        throw CustomAuthenticationErrors.unknownError(error.localizedDescription)
    }
}

func getUserToken() async throws -> String {
    guard let user = Auth.auth().currentUser else {
        throw CustomAuthenticationErrors.userNotFound
    }
    do {
        let token = try await user.getIDToken()
        return token
    } catch {
        throw CustomAuthenticationErrors.unknownError(error.localizedDescription)
    }
}

enum CustomAuthenticationErrors: LocalizedError {
    case userNotFound
    case emailVerificationFailed
    case invalidCredentials
    case signOutFailed
    case providerOptionNotFound(String)
    case unknownError(String)
    case requiresReauthentication
    case deleteUserDefaultFailed(String)

    var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "No authenticated user was found."
            case .emailVerificationFailed:
                return "Failed to send email verification."
            case .invalidCredentials:
                return "The provided credentials are invalid."
            case .signOutFailed:
                return "Sign out operation failed."
            case .providerOptionNotFound(let providerID):
                return "Provider option not recognized: \(providerID)"
            case .requiresReauthentication:
                        return "Reauthentication is required before deleting your account."
            case .unknownError(let message):
                return "An unknown error occurred: \(message)"
            case .deleteUserDefaultFailed(let message):
                return "Failed to delete user defaults: \(message)"
            }
        }
    }

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw CustomAuthenticationErrors.userNotFound
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func getcurrentEmailProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else{
            throw CustomAuthenticationErrors.userNotFound
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                throw CustomAuthenticationErrors.providerOptionNotFound(provider.providerID)
            }
        }
        print(providers)
        return providers
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "userSession")
        UserDefaults.standard.synchronize()
        try await resetUserDefaults()
        print("User signed out successfully")
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw CustomAuthenticationErrors.userNotFound
        }

        let userID = user.uid
        let db = Firestore.firestore()

        do {
            try await db.collection("users").document(userID).delete()
            print("User document deleted from Firestore")

            try await user.delete()
            print("User deleted from Firebase Authentication")
            
           try await resetUserDefaults()
            print("User defaults reset")
        } catch {
            if let errorCode = (error as NSError?)?.code,
               errorCode == AuthErrorCode.requiresRecentLogin.rawValue {
                throw CustomAuthenticationErrors.requiresReauthentication
            } else {
                throw CustomAuthenticationErrors.unknownError(error.localizedDescription)
            }
        }
    }

    
    
    func sendEmailVerification() throws {
        guard let user = Auth.auth().currentUser else {
            throw CustomAuthenticationErrors.userNotFound
        }
        
        user.sendEmailVerification { error in
            if let error = error {
                print("Failed to send email verification: \(error.localizedDescription)")
            } else {
                print("Email verification sent successfully.")
            }
        }
    }
    
    func resetUserDefaults()async throws{
        let keysToRemove = ["workoutPlan", "workoutMetadata"]
        let defaults = UserDefaults.standard

        for key in keysToRemove {
            defaults.removeObject(forKey: key)
            if defaults.object(forKey: key) != nil {
                throw CustomAuthenticationErrors.deleteUserDefaultFailed("Failed to remove key: \(key)")
            } else {
                print("Removed key: \(key)")
            }
        }

        defaults.synchronize() //Optional according to StackOverflow. Does not seem to impact functionality, leaving here just in case.
    }


    
}

//SignIn Email Functions

extension AuthenticationManager {
    
    //Discarable meaning we don't need the result (added to avoid warnings)
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = authDataResult.user
        
        // This sends email verification
        try await user.sendEmailVerification()
        
        // This creates a Firestore entry
        let authDataModel = AuthDataResultModel(user: user)
        let dbUser = DBUser(auth: authDataModel)
        try await UserManager.shared.createNewUser(user: dbUser)
        
        return authDataModel
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = authDataResult.user
        
        guard user.isEmailVerified else {
            print("User email is not verified: \(user.email ?? "Uknown email")")
            throw CustomAuthenticationErrors.emailVerificationFailed
        }
        return AuthDataResultModel(user: user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func resendEmailVerification() throws {
        guard let user = Auth.auth().currentUser else {
            throw CustomAuthenticationErrors.userNotFound
        }
        
        user.sendEmailVerification { error in
            if let error = error {
                print("Error resending verification email: \(error.localizedDescription)")
            } else {
                print("Verification email resent successfully.")
            }
        }
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.sendEmailVerification(beforeUpdatingEmail: email) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

//SignIn SSO Functions

extension AuthenticationManager {
    
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

extension AuthenticationManager {
    
    func reauthenticateUser(email:String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw CustomAuthenticationErrors.userNotFound
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
        } catch {
            throw CustomAuthenticationErrors.unknownError(error.localizedDescription)
        }
    }
    
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
