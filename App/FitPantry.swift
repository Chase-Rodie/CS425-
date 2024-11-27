//
//  FitPantryApp.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 9/26/24.
//

import SwiftUI
import Firebase
import FirebaseCore

@main
struct Fit_PantryApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                //AuthenticationView()
               // WorkoutView()
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application( application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

