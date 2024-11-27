//
//  TempContentView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/15/24.
//

import SwiftUI

struct TempContentView: View {
    var body: some View {
        //TabView is for the bottom navigation menu
                TabView{
                    HomeView()
                        .tabItem(){
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    WorkoutView()
                        .tabItem(){
                            Image(systemName: "figure.run")
                            Text("Exercise1")
                        }
                
                }
    }
}

#Preview {
    TempContentView()
}
