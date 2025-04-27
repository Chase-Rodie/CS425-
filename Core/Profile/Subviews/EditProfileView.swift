//
//  EditProfileView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 2/11/25.
//

import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var showProfilePopup: Bool
    @State private var editedUser: DBUser?
    @State private var showSavedMessage = false

    
    var body: some View {
        Form {
            if let _ = editedUser {
                Section(header: Text("Personal Information")) {
                    
                    TextField("Name", text: Binding(
                        get: { editedUser?.profile.name ?? "" },
                        set: { editedUser?.profile.name = $0 }
                    ))
                    
                    TextField("Age", text: Binding(
                        get: { editedUser?.profile.age.map { "\($0)" } ?? "" },
                        set: { editedUser?.profile.age = Int($0) }
                    ))
                    .keyboardType(.numberPad)
                    
                    TextField("Gender", text: Binding(
                        get: { editedUser?.profile.gender?.rawValue ?? "" },
                        set: { editedUser?.profile.gender = Gender(rawValue: $0) }
                    ))
                    
                    Picker("Fitness Level", selection: Binding(
                        get: { editedUser?.profile.fitnessLevel?.rawValue ?? "" },
                        set: { editedUser?.profile.fitnessLevel = FitnessLevel(rawValue: $0) }
                    )) {
                        Text("Beginner").tag("Beginner")
                        Text("Intermediate").tag("Intermediate")
                        Text("Advanced").tag("Advanced")
                    }
                    
                    Picker("Fitness Goal", selection: Binding(
                        get: { editedUser?.profile.goal?.rawValue ?? "" },
                        set: { editedUser?.profile.goal = Goal(rawValue: $0) }
                    )) {
                        Text("Lose Weight").tag("LoseWeight")
                        Text("Gain Weight").tag("GainWeight")
                        Text("Maintain Weight").tag("MaintainWeight")
                    }

                    TextField("Height", text: Binding(
                        get: { editedUser?.profile.height ?? "" },
                        set: { editedUser?.profile.height = $0 }
                    ))

                    TextField("Weight", text: Binding(
                        get: { editedUser?.profile.weight ?? "" },
                        set: { editedUser?.profile.weight = $0 }
                    ))
                }

                Button(action: {
                    Task {
                        await saveProfile()
                        setProfileCompleted()
                        showProfilePopup = false
                        showSavedMessage = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSavedMessage = false
                        }
                    }
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                
                if showSavedMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Profile saved!")
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                    .padding(.top, 8)
                    .transition(.opacity)
                }


            } else {
                Text("Loading profile...").foregroundColor(.gray)
            }
        }

        .navigationTitle("Edit Profile")
        .onAppear {
            Task {
                await loadUser()
            }
        }
        .onChange(of: viewModel.user) { _ in
            self.editedUser = viewModel.user
        }
    }
    
    private func loadUser() async {
        do {
            try await viewModel.loadCurrentUser()
            DispatchQueue.main.async {
                if let user = viewModel.user {
                    self.editedUser = user
                    print("EditProfileView received user data: \(user)")
                } else {
                    print("EditProfileView: No user data received.")
                }
            }
        } catch {
            print("Error loading user: \(error)")
        }
    }
    
    private func saveProfile() async {
        guard let updatedUser = editedUser else {
            print("No user data to save")
            return
        }

        do {
            try await viewModel.updateUserProfile(user: updatedUser)
            print("Successfully updated profile: \(updatedUser)")
            await loadUser()
            DispatchQueue.main.async {
                viewModel.user = updatedUser
            }
        } catch {
            print("Error updating profile: \(error)")
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
                print("Profile marked as completed after edit!")
            }
        }
    }



}
