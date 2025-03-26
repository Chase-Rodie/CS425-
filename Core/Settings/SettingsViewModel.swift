//
//  SettingsViewModel.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 12/2/24.
//

//Used Firebase documentation to learn how to handle linking accounts
//https://firebase.google.com/docs/auth/ios/account-linking

//Logic for functions in the settings view relating to updating email, updating password, etc.

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    @Published var showReauthAlert: Bool = false  // 🔥 Add this

    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getcurrentEmailProvider() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "helloemail@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hello456"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        self.authUser = authDataResult
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.linkApple(tokens: tokens)
        self.authUser = authDataResult
    }
    
    //Create UI for email, text fields with whole other screen
    func linkEmailAccount() async throws {
        let email = "hello234@gmail.com"
        let password = "Hello234@"
        let authDataResult = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        self.authUser = authDataResult
    }
    
    func deleteAccount() async {
            do {
                try await AuthenticationManager.shared.deleteUser()
                print("Account deletion successful")
            } catch CustomAuthenticationErrors.requiresReauthentication {
                showReauthAlert = true
            } catch {
                print("Error deleting account: \(error)")
            }
        }

    func reauthenticateUser(email: String, password: String) async throws {
        try await AuthenticationManager.shared.reauthenticateUser(email: email, password: password)
    }
}
