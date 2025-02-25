//
//  ProfileView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 12/2/24.
//  Edited by Heather Amistani on 02/18/2024
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DatabaseUser? = nil
    @Published var profileImage: UIImage? = nil
    
    func loadCurrentUser() async throws {
        let  authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func loadProfileImage(from url: String) async{
        guard let imageUrl = URL(string: url) else {return}
        
        do{
            let data = try Data(contentsOf: imageUrl)
            DispatchQueue.main.async{
                self.profileImage = UIImage(data:data)
            }
        } catch{
            print("Error loading image: \(error)")
        }
    }
    
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView{
            VStack{
                Image("User")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding()
            }
            List {
                if let user = viewModel.user {
                    Section(header: Text("Personal Info")){
                        Text("Email: \(user.email ?? "N/A")")
                        Text("Gender: \(user.gender ?? "N/A")")
                        //Text("Weight: \(user.weight ?? "N/A") lbs")
                        Text("Weight: \(user.weight.map { String(format: "%.1f", $0) } ?? "N/A") lbs")

                        Text("Height: \(user.height ?? "N/A") inches")
                        Text("Allergies: \(user.allergies?.joined(separator: ", ") ?? "None")")
                        Text("Exercise Level: \(user.exerciseLevel?.capitalized ?? "N/A")")
                    }
                    //                Text("UserId: \(user.userId)")
                    //
                    //                if let isAnonymous = user.isAnonymous {
                    //                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                    //                }
                    //            }
                }
                Section{
                    NavigationLink(destination: EditProfileView(user: viewModel.user)){
                        Text("EditProfile")
                            .foregroundColor(.blue)
                    }
                }
                .task {
                    try? await viewModel.loadCurrentUser()
                }
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink { SettingsView(showSignInView: $showSignInView)
                        } label: {
                            Image(systemName: "gear")
                                .font(.headline)
                        }
                    }
                }
            }
        }
    }
    
    struct EditProfileView: View{
        var user: DatabaseUser?
        var body: some View{
            Text("Edit Profile Screen")
                .navigationTitle("Edit Profile")
        }
    }
    
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationStack {
                ProfileView(showSignInView: .constant(false))
            }
        }
    }
}
