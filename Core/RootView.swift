//
//  RootView.swift
//  Fit Pantry
// 
//  Created by Chase Rodie on 11/23/24.
//

//Entire group worked on this to handle how app went from it's entry to subsequent views

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @State private var showMenu: Bool = false
    @State private var showPantryView: Bool = false
    @State private var showProfileView: Bool = false
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    AddFoodView()

                    Button("View Pantry") {
                        showPantryView = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .navigationDestination(isPresented: $showPantryView) {
                        PantryView()
                    }
                    .navigationBarItems(trailing:
                        Button(action: {
                            showProfileView = true
                        }) {
                            Text("Profile")
                                .foregroundColor(.blue)
                        }
                    )
                    .navigationDestination(isPresented: $showProfileView) {
                        ProfileView(showSignInView: $showSignInView)
                    }
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
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
