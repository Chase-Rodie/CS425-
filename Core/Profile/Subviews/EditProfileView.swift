//
//  EditProfileView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 2/11/25.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editedUser: DBUser?
    
    var body: some View {
        Form {
            if let user = editedUser {
                Section(header: Text("Personal Information")) {
                    TextField("Age", text: Binding(
                        get: { user.age.map { "\($0)" } ?? "" },
                        set: { editedUser?.age = $0.isEmpty ? nil : Int($0) }
                    ))
                    .keyboardType(.numberPad)
                    
                    TextField("Gender", text: Binding(
                        get: { user.gender ?? "" },
                        set: { editedUser?.gender = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Fitness Level", text: Binding(
                        get: { user.fitnessLevel ?? "" },
                        set: { editedUser?.fitnessLevel = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Goal", text: Binding(
                        get: { user.goal ?? "" },
                        set: { editedUser?.goal = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Height", text: Binding(
                        get: { user.height ?? "" },
                        set: { editedUser?.height = $0.isEmpty ? nil : $0 }
                    ))
                    
                    TextField("Weight", text: Binding(
                        get: { user.weight ?? "" },
                        set: { editedUser?.weight = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Button("Save Changes") {
                    Task {
                        await saveProfile()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
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

        print("Attempting to save profile with the following data: \(updatedUser)")

        do {
            try await viewModel.updateUserProfile(user: updatedUser)

            print("Successfully updated profile: \(updatedUser)")

            await loadUser()

            DispatchQueue.main.async {
                viewModel.user = updatedUser
                dismiss()
            }
        } catch {
            print("Error updating profile: \(error)")
        }
    }

}
