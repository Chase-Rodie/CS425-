//
//  TempContentView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/30/24.
//

import SwiftUI

import SwiftUI

struct TempContentView: View {
    @State private var selectedTab = 0
    @State var showMenu = false
    @Binding var showSignInView: Bool
    @State private var dragOffset: CGFloat = 0  

    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showMenu = false
                    }
                }
            }
        
        ZStack(alignment: .leading) {
            TabView(selection: $selectedTab) {
                HomePageView(showMenu: self.$showMenu)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                WorkoutView()
                    .tabItem { Label("Workout", systemImage: "figure.run") }
                    .tag(1)

                FoodJournalView()
                    .tabItem { Label("Food Journal", systemImage: "fork.knife.circle.fill") }
                    .tag(2)

                PantryView()
                    .tabItem { Label("Pantry", systemImage: "cart.fill") }
                    .tag(3)

                NavigationStack {
                    ProfileView(showSignInView: $showSignInView)
                }
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
                
                NavigationStack {
                    SettingsView(showSignInView: $showSignInView)
                }
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(5)
            }
            .accentColor(Color("BackgroundColor"))

            
            HStack {
                if self.showMenu {
                    HamburgerMenuView()
                        .frame(width: UIScreen.main.bounds.width / 1.5)
                        .background(Color("LighterColor"))
                        .transition(.move(edge: .leading)) // Slide in animation
                        .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width / 1.5)
                        .animation(.easeInOut(duration: 0.3))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .gesture(drag)
        }
    }
}

struct TempContentView_Previews: PreviewProvider {
    static var previews: some View {
        TempContentView(showSignInView: .constant(false))
    }
}
