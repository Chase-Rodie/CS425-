//
//  SignUpEmailView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 3/1/25.
//

import SwiftUI

struct SignUpEmailView: View {
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var emailErrorMessage: String? = nil

    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: viewModel.email) { _ in
                    emailErrorMessage = nil
                }

            if let emailErrorMessage = emailErrorMessage {
                Text(emailErrorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            HStack {
                if showPassword {
                    TextField("Password...", text: $viewModel.password)
                } else {
                    SecureField("Password...", text: $viewModel.password)
                        .textContentType(.oneTimeCode)
                }
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            HStack {
                if showConfirmPassword {
                    TextField("Confirm Password...", text: $viewModel.confirmPassword)
                } else {
                    SecureField("Confirm Password...", text: $viewModel.confirmPassword)
                        .textContentType(.oneTimeCode)
                }
                Button(action: { showConfirmPassword.toggle() }) {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)

            Button {
                if isPasswordTooSimple(viewModel.password) {
                    emailErrorMessage = "Password must be at least 6 characters long and include at least one number and one special character."
                } else {
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                        } catch {
                            print("Sign Up Failed: \(error)")
                        }
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up With Email")
    }
    
    private func isPasswordTooSimple(_ password: String) -> Bool {
        let regex = "^(?=.*[0-9])(?=.*[A-Za-z])(?=.*[!@#$%^&*(),.?\":{}|<>]).{6,}$"
        return password.range(of: regex, options: .regularExpression) == nil
    }

}

struct SignUpEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpEmailView(showSignInView: .constant(false))
        }
    }
}
