//
//  WorkoutView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 10/31/24.
//

import SwiftUI
import Foundation

struct WorkoutView: View {
    var body: some View {
        VStack {
            Image(systemName: "figure.highintensity.intervaltraining")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("WorkoutView Test")
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
        }
        .padding()
    }
}

#Preview {
    WorkoutView()
}
