//
//  ContentView.swift
//  Capstone Project
//
//  Created by Chase Rodie on 9/26/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("This is a test!")
        }
        TabView{
            HomeView()
                .tabItem(){
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            WorkoutView()
                .tabItem(){
                    Image(systemName: "figure.run")
                    Text("Exercise")
                }
            WorkoutView()
                .tabItem(){
                    Image(systemName: "fork.knife.circle.fill")
                    Text("Pantry")
                }
            WorkoutView()
                .tabItem(){
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            WorkoutView()
                .tabItem(){
                    Image(systemName: "person.fill")
                    Text("Scan")
                }
        }
        
        .padding()
    }
}

#Preview {
    MainView()
}

