//
//  RootView.swift
//  Fit Pantry
// 
//  Created by Chase Rodie on 11/23/24.
//

//Entire group worked on this to handle how app went from it's entry to subsequent views

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false // Tracks if login is required
    
    var body: some View {
        ZStack {
            if showSignInView {
                // If we need to show the SignIn View
                AuthenticationView(showSignInView: $showSignInView)
                    .onAppear {
                        // Check the authentication status right when this view is shown
                        checkAuthStatus()
                    }
            } else {
                // Show TempContentView once logged in
                TempContentView()
            }
        }
        .onAppear {
            // Check if the user is authenticated when RootView appears
            checkAuthStatus()
        }
    }
    
    // Helper function to check user authentication
    private func checkAuthStatus() {
        // Check if there's an authenticated user, otherwise show the sign-in screen
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        } catch {
            self.showSignInView = true // If no user is authenticated, show the sign-in view
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
