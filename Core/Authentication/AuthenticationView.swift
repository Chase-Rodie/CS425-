//
//  AuthenticationView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

enum AuthRoute: Hashable {
    case onboarding
    case verification
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var userManager: UserManager
    @Binding var showSignInView: Bool
    @State private var isReturningUser: Bool = true
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                Picker("Authentication Type", selection: $isReturningUser) {
                    Text("Sign In").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                NavigationLink {
                    if isReturningUser {
                        SignInEmailView(showSignInView: $showSignInView)
                    } else {
                        SignUpEmailView(showSignInView: $showSignInView)
                    }
                } label: {
                    Text(isReturningUser ? "Sign In with Email" : "Sign Up with Email")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 375)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                }
                .padding(.bottom, 15)
                
                // Google Sign-In
                Button {
                    Task {
                        await handleThirdPartySignIn(provider: .google)
                    }
                } label: {
                    HStack {
                        Image("GoogleButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("Sign in with Google")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // Apple Sign-In
                Button {
                    Task {
                        await handleThirdPartySignIn(provider: .apple)
                    }
                } label: {
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .allowsHitTesting(false)
                }
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // Guest
                HStack {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.signInAnonymous()
                                showSignInView = false
                            } catch {
                                print(error)
                            }
                        }
                    }) {
                        Text("Continue as Guest")
                            .font(.body)
                            .foregroundColor(.gray)
                            .underline()
                    }
                    Spacer()
                }
                .padding(.leading)
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .onboarding:
                    OnboardingView(showSignInView: $showSignInView)
                case .verification:
                    EmailVerificationView(showSignInView: $showSignInView)
                }
            }
        }
    }
    
    private enum SignInProvider {
        case google, apple
    }

    private func handleThirdPartySignIn(provider: SignInProvider) async {
        do {
            switch provider {
            case .google:
                try await viewModel.signInGoogle()
            case .apple:
                try await viewModel.signInApple()
            }

            await userManager.fetchCurrentUser()
            
            if needsOnboarding() {
                path.append(.onboarding)
            } else {
                showSignInView = false
            }
        } catch {
            print("Error during third-party sign-in: \(error)")
        }
    }

    private func needsOnboarding() -> Bool {
        guard let profile = userManager.currentUser?.profile else { return true }
        return profile.name == nil || profile.name?.isEmpty == true
    }
}

