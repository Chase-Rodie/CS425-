//
//  AuthenticationManager.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
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

enum CustomAuthenticationErrors: LocalizedError {
    case userNotFound
    case emailVerificationFailed
    case invalidCredentials
    case signOutFailed
    case providerOptionNotFound(String)
    case unknownError(String)
    
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
            case .unknownError(let message):
                return "An unknown error occurred: \(message)"
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
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw CustomAuthenticationErrors.userNotFound
        }
        do {
            try await user.delete()
        } catch {
            throw CustomAuthenticationErrors.unknownError(error.localizedDescription)
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
}

//SignIn Email Functions

extension AuthenticationManager {
    
    //Discarable meaning we don't need the result (added to avoid warnings)
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
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
