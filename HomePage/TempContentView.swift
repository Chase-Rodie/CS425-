//
//  TempContentView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/30/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TempContentView: View {
    @State private var selectedTab = 0
    @State var showMenu = false
    @Binding var showSignInView: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var navigateToEditProfile = false
    @State private var showProfilePopup = false
    @ObservedObject var viewModel: ProfileViewModel
    @State private var profileCompleted = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                
                Color("BackgroundColor")
                    .ignoresSafeArea()
                    .zIndex(-1)

                TabView(selection: $selectedTab) {
                    NavigationStack { FoodJournalView() }
                        .tabItem { Label("Food Journal", systemImage: "book.fill") }
                        .tag(2)

                    NavigationStack { MainWorkoutView() }
                        .tabItem { Label("Workout", systemImage: "figure.run") }
                        .tag(1)

                    NavigationStack { HomePageView(viewModel: viewModel, showSignInView: $showSignInView) }
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
                        GoalsView(user: UserMeal(
                            age: 24,
                            weightInLbs: 160,
                            heightInFeet: 5,
                            heightInInches: 10,
                            gender: "Male",
                            dietaryRestrictions: [],
                            goal: "Gain Weight",
                            activityLevel: "Active",
                            mealPreferences: []
                        ))
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
                }
                .accentColor(Color("BackgroundColor"))
                
                // Profile completion popup
                if showProfilePopup && !profileCompleted {
                    VStack {
                        Text("Would you like to complete your profile?")
                            .font(.headline)
                            .padding()

                        HStack {
                            Button("Yes") {
                                navigateToEditProfile = true
                                showProfilePopup = false
                            }
                            .padding()

                            Button("No") {
                                setProfileCompleted()
                                showProfilePopup = false  
                            }
                            .padding()
                        }
                    }
                    .frame(width: 300, height: 200)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(40)
                }
            }
            .onAppear {
                if let loginMethod = UserDefaults.standard.string(forKey: "loginMethod"),
                   (loginMethod == "google" || loginMethod == "apple") {
                    checkProfileCompletion()
                }
            }

            // Navigation link to edit profile view
            NavigationLink(
                "",
                destination: EditProfileView(viewModel: viewModel, showProfilePopup: $showProfilePopup),
                isActive: $navigateToEditProfile
            )
            .hidden()
        }
    }

    func checkProfileCompletion() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let profileCompleted = data?["profileCompleted"] as? Bool ?? false
                if !profileCompleted {
                    self.showProfilePopup = true
                } else {
                    self.profileCompleted = true  // Set as completed
                }
            } else {
                print("No user document found or error: \(error?.localizedDescription ?? "Unknown error")")
                self.showProfilePopup = true
            }
        }
    }

    func setProfileCompleted() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "profileCompleted": true
        ]) { error in
            if let error = error {
                print("Error updating profileCompleted: \(error)")
            } else {
                print("Profile marked as completed.")
            }
        }
    }
}

struct TempContentView_Previews: PreviewProvider {
    static var previews: some View {
        TempContentView(showSignInView: .constant(false), viewModel: ProfileViewModel())
    }
}
