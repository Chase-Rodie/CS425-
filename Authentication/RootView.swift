//
//  RootView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    //HomePageView()
                    //SettingsView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            // Force logout by clearing the authenticated user
            try? AuthenticationManager.shared.signOut() // Ensure this method exists to handle logout
            self.showSignInView = true
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
