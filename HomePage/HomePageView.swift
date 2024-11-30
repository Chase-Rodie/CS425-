//
//  HomePageView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/29/24.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        
        
        //this tab view will need to be used on the home page after a user logs in.
        TabView {
            WorkoutView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "figure.run")
                }
            WorkoutView()
                .tabItem {
                    Label("Pantry", systemImage: "fork.knife.circle.fill")
                }
            WorkoutView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            WorkoutView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                
                }
            
    }
}

#Preview {
    HomePageView()
}
