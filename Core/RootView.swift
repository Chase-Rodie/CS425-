//
//  RootView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 11/23/24.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            if !showSignInView {
                TempContentView(showSignInView: $showSignInView, viewModel: viewModel)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
            HealthKitManager.shared.requestAuthorization { success in
                print(success ? "HealthKit Authorized!" : "HealthKit Not authorized")
            }
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
