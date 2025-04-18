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
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
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

                NavigationLink(destination: OnboardingView(showSignInView: $showSignInView), isActive: $showOnboarding) {
                    EmptyView()
                }
            }
            .padding()
        }
    }

    func checkVerificationStatus() async {
        do {
            let user = Auth.auth().currentUser
            try await user?.reload()  

            if user?.isEmailVerified == true {
                DispatchQueue.main.async {
                    self.showOnboarding = true
                }
                print("Email verified, moving to onboarding")
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Your email is not verified yet. Please check your inbox."
                }
                print("Email is not verified")
            }
        } catch {
            print("Failed to reload user: \(error.localizedDescription)")
        }
    }


    func resendVerificationEmail() {
        let user = Auth.auth().currentUser
        user?.sendEmailVerification { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error resending email: \(error.localizedDescription)"
                } else {
                    self.errorMessage = "Verification email sent again. Check your inbox!"
                }
            }
        }
    }
}
