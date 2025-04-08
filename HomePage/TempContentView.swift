//
//  TempContentView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/30/24.
//

import SwiftUI

struct TempContentView: View {
    
    @State var showMenu = false
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            TabView(selection: $selectedTab) {
                NavigationStack { FoodJournalView() }
                    .tabItem { Label("Food Journal", systemImage: "book.fill") }
                    .tag(2)
                
                NavigationStack { WorkoutView() }
                    .tabItem { Label("Workout", systemImage: "figure.run") }
                    .tag(1)
                
                NavigationStack { HomePageView(showSignInView: $showSignInView) }
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                NavigationStack { MealPlanView() }
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        ZStack(alignment: .leading){
            
        TabView {
            HomePageView(showMenu: self.$showMenu)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "figure.run")
                }
            FoodJournalView()
                .tabItem {
                    Label("Food Journal", systemImage: "fork.knife.circle.fill")
                }
            PantryView()
                .tabItem {
                    Label("Pantry", systemImage: "fork.knife.circle.fill")
                }
            MealPlanView()
                .tabItem {
                    Label("Meal Planner", systemImage: "calendar")
                }
            ShoppingListView()
                .tabItem {
                    Label("Shopping List", systemImage: "cart.fill")
                }
            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            SettingsView(showSignInView: $showSignInView)                
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
        }
        .accentColor(Color("BackgroundColor"))
            if self.showMenu{
                HamburgerMenuView()
                    .frame(width: UIScreen.main.bounds.width/1.5)
                    .transition(.move(edge:.leading))
                    
            }
        }
    }
}


//struct TempContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        TempContentView(showSignInView: .constant(false))
//    }
//}

struct TempContentView_Previews: PreviewProvider {
    static var previews: some View {
        TempContentView(showSignInView: .constant(false))
            .environmentObject(TodayMealManager()) // 👈 This line fixes the crash!
    }
}
