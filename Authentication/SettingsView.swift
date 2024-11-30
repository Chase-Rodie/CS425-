//
//  SettingsView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getcurrentEmailProvider() {
            authProviders = providers
        }
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
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
           
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
        }
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .navigationBarTitle("Settings")
    }
}
    
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSignInView: .constant(false))
        }
    }
}


extension SettingsView {
    
    private var emailSection: some View{
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET")
                    } catch {
                        print(error)
                    }
                }
            }
        
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("Updated Password")
                    }catch {
                        print(error)
                    }
                }
            }
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Updated Email")
                    }catch {
                        print(error)
                    }
                }
            }
            } header: {
                Text("Email functions")
        }
    }
}


//Have some sort of intermediate screen so that user can update password/email in app rather than signing in/out to reauthetnicate

//Also create custom errors rather than doing print(error)
