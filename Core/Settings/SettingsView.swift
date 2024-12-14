//
//  SettingsView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

//UI View for the users setting page

import SwiftUI

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
            
            Button(role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            print("Account Deleted")
                        }catch {
                            print(error)
                        }
                    }
            } label: {
                Text("Delete Account")
            }
           
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
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

//Instead of link buttons use actual UI sign in buttons that are on sign in screen (future implementation)
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
    
    private var anonymousSection: some View{
        Section {
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("Linked Email Account")
                    } catch {
                        print(error)
                    }
                }
            }
        
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("Linked Google Account")
                    }catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("Linked Apple Account")
                    }catch {
                        print(error)
                    }
                }
            }
            } header: {
                Text("Create account")
        }
    }
}


//Have some sort of intermediate screen so that user can update password/email in app rather than signing in/out to reauthetnicate

//Also create custom errors rather than doing print(error)
