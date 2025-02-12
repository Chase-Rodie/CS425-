//
//  RootView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/21/23.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                TempContentView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
<<<<<<< Updated upstream
            // Check if the user is authenticated when RootView appears
            checkAuthStatus()
        }
    }
    
    // Helper function to check user authentication
    private func checkAuthStatus() {
        // Check if there's an authenticated user, otherwise show the sign-in screen
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
=======
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
>>>>>>> Stashed changes
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
