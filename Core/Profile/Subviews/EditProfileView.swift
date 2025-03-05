import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editedUser: DBUser

    init(viewModel: ProfileViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _editedUser = State(initialValue: viewModel.user ?? DBUser(userId: "", age: nil, gender: nil, fitnessLevel: nil, goal: nil, weight: nil, height: nil)) // Default values
    }
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Age", text: Binding(
                    get: { editedUser.age.map { "\($0)" } ?? "" },
                    set: { editedUser.age = $0.isEmpty ? nil : Int($0) }
                ))
                .keyboardType(.numberPad)
                
                TextField("Gender", text: Binding(
                    get: { editedUser.gender ?? "" },
                    set: { editedUser.gender = $0.isEmpty ? nil : $0 }
                ))

                TextField("Fitness Level", text: Binding(
                    get: { editedUser.fitnessLevel ?? "" },
                    set: { editedUser.fitnessLevel = $0.isEmpty ? nil : $0 }
                ))

                TextField("Goal", text: Binding(
                    get: { editedUser.goal ?? "" },
                    set: { editedUser.goal = $0.isEmpty ? nil : $0 }
                ))
                
                TextField("Height", text: Binding(
                    get: { editedUser.height ?? "" },
                    set: { editedUser.height = $0.isEmpty ? nil : $0 }
                ))
                
                TextField("Weight", text: Binding(
                    get: { editedUser.weight ?? "" },
                    set: { editedUser.height = $0.isEmpty ? nil : $0}
                ))
            }
            
            Button("Save Changes") {
                Task {
                    await saveProfile()
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Edit Profile")
    }
    
    private func saveProfile() async {
        print("Saving user: \(editedUser)") 

        do {
            try await viewModel.updateUserProfile(user: editedUser)
            DispatchQueue.main.async {
                viewModel.user = editedUser
                dismiss()
            }
        } catch {
            print("Error updating profile: \(error)")
        }
    }
}
