//
//  Fit_PantryApp.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 9/26/24.
//

//Entire group worked on this to implement how the entry of the app was handled

import SwiftUI
import Firebase
import FirebaseCore

@main
struct Fit_PantryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userManager = UserManager.shared
    @StateObject private var mealManager = TodayMealManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                    .environmentObject(userManager)
                    .environmentObject(mealManager)
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
