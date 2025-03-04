//
//  SignUpEmailViewModel.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 3/1/25.
//

import Foundation

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            print("All fields must be filled.")
            return
        }
        
        guard password == confirmPassword else {
            print("Passwords do not match.")
            return
        }

        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}

