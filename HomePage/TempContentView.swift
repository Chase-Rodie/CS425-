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
        
        
        let drag =  DragGesture()
            .onEnded{
                if $0.translation.width < -100 {
                    withAnimation{
                        self.showMenu = false
                    }
                }
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
            FoodJournalView(userId:"Uhq3C2AQ05apw4yETqgyIl8mXzk2")
                .tabItem {
                    Label("Food Journal", systemImage: "fork.knife.circle.fill")
                }
            PantryView()
                .tabItem {
                    Label("Pantry", systemImage: "fork.knife.circle.fill")
                }
            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            SettingsView(showSignInView: $showSignInView)                .tabItem {
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
        .gesture(drag)
    }
}


struct TempContentView_Previews: PreviewProvider {
    static var previews: some View {
        TempContentView(showSignInView: .constant(false))
    }
}
