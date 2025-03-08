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
//        let drag = DragGesture()
//            .onEnded {
//                if $0.translation.width < -100 {
//                    withAnimation {
//                        self.showMenu = false
//                    }
//                }
//            }
        
        ZStack(alignment: .leading) {
            TabView(selection: $selectedTab) {
                FoodJournalView()
                    .tabItem { Label("Food Journal", systemImage: "book.fill") }
                    .tag(2)

                WorkoutView()
                    .tabItem { Label("Workout", systemImage: "figure.run") }
                    .tag(1)
                
                HomePageView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                MealPlanView()
                    .tabItem { Label("Meal", systemImage: "fork.knife.circle.fill") }
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
                
                NavigationStack {
                    GoalsView()
                }
                .tabItem { Label("Goals", systemImage: "target") }
                .tag(6)
                
                NavigationStack {
                    ShoppingListView()
                }
                .tabItem { Label("Shopping List", systemImage: "list.bullet") }
                .tag(7)
                
                NavigationStack {
                    PantryView()
                }
                .tabItem { Label("Pantry", systemImage: "cart") }
                .tag(8)
                
                NavigationStack {
                    FavoriteMealView()
                }
                .tabItem { Label("Favorite Meals", systemImage: "star") }
                .tag(9)
                
                NavigationStack {
                    ProgressionView()
                }
                .tabItem { Label("Progress", systemImage: "progress.indicator") }
                .tag(10)
                
                
                NavigationStack {
                    FriendsView()
                }
                .tabItem { Label("Friends", systemImage: "person.3") }
                .tag(11)
               
                NavigationStack {
                    AppsDevicesView()
                }
                .tabItem { Label("Apps/Devices", systemImage: "square.stack.3d.up") }
                .tag(12)
                
                NavigationStack {
                    PrivacyInfoView()
                }
                .tabItem { Label("Privacy Center", systemImage: "hand.raised") }
                .tag(13)
            }
            .accentColor(Color("BackgroundColor"))

            
//            HStack {
//                if self.showMenu {
//                    HamburgerMenuView()
//                        .frame(width: UIScreen.main.bounds.width / 1.5)
//                        .background(Color("LighterColor"))
//                        .transition(.move(edge: .leading)) // Slide in animation
//                        .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width / 1.5)
//                        .animation(.easeInOut(duration: 0.3))
//                }
//                Spacer()
//            }
            .frame(maxWidth: .infinity, alignment: .leading)
//            .gesture(drag)
        }
    }
}

struct TempContentView_Previews: PreviewProvider {
    static var previews: some View {
        TempContentView(showSignInView: .constant(false))
    }
}
