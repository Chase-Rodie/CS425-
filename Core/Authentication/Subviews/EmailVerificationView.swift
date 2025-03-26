//
//  EmailVerificationView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 3/21/25.
//

import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @State private var isVerified = false
    @State private var errorMessage: String?
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            Image(systemName: "envelope.badge")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Verify Your Email")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            Text("We have sent a verification email to your inbox. Please verify your email before continuing.")
                .multilineTextAlignment(.center)
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Check Verification Status") {
                Task {
                    await checkVerificationStatus()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Resend Verification Email") {
                resendVerificationEmail()
            }
            .padding(.top, 10)
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    func checkVerificationStatus() async {
        do {
            let user = Auth.auth().currentUser
            do {
                try await user?.reload()
            } catch {
                print("Failed to reload user: \(error.localizedDescription)")
            }
            if user?.isEmailVerified == true {
                isVerified = true
                showSignInView = false 
            } else {
                errorMessage = "Your email is not verified yet. Please check your inbox."
            }
        }
    }
    
    func resendVerificationEmail() {
        let user = Auth.auth().currentUser
        user?.sendEmailVerification { error in
            if let error = error {
                errorMessage = "Error resending email: \(error.localizedDescription)"
            } else {
                errorMessage = "Verification email sent again. Check your inbox!"
            }
        }
    }
}



struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EmailVerificationView(showSignInView: .constant(false))
        }
    }
}
