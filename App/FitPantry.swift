//
//  Fit_PantryApp.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 9/26/24.
//

<<<<<<< Updated upstream
=======
//Entire group worked on this to implement how the entry of the app was handled 

>>>>>>> Stashed changes
import SwiftUI
import Firebase
import FirebaseCore

@main
struct Fit_PantryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
                
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
