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
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            HStack {
                if showPassword {
                    TextField("Password...", text: $viewModel.password)
                } else {
                    SecureField("Password...", text: $viewModel.password)
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
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                    } catch {
                        print("Sign Up Failed: \(error)")
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
}

struct SignUpEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpEmailView(showSignInView: .constant(false))
        }
    }
}

