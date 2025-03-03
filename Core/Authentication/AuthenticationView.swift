//
//  AuthenticationView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

//This is the UI for the various different types of authentication: email, apple, etc.

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            // Logo at the top
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 30)

            // Sign In Button - Anonymous
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign In Anonymously")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(20)
                    .shadow(radius: 10)
            })
            .padding(.bottom, 15)

            // Email Sign-In
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(20)
                    .shadow(radius: 10)
            }
            .padding(.bottom, 15)

            // Google Sign-In Button
            
            VStack(spacing: 15) {
                // Google Sign-In Button (Now on Top)
                Button {
                    print("Tapped Google sign-in")
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
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
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

                // Apple Sign-In Button (Now Below Google)
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signInApple()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }, label: {
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .allowsHitTesting(false)
                })
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }


        }
        .padding()
        .padding()
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
