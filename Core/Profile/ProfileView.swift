//
//  ProfileView.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 12/2/24.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            List {
                if let user = viewModel.user {
                    Section {
                        NavigationLink {
                            EditProfileView(viewModel: viewModel, showProfilePopup: .constant(false))
                        } label: {
                            Text("Edit Profile")
                        }

                        NavigationLink {
                            EditPreferencesView(viewModel: viewModel)
                        } label: {
                            Text("Edit Dietary Preferences & Allergies")
                        }
                    }

//                    Section {
//                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
//                            Text("Select a photo")
//                        }
//
//                        if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
//                            AsyncImage(url: url) { image in
//                                image.resizable()
//                                    .scaledToFill()
//                                    .frame(width: 150, height: 150)
//                                    .cornerRadius(10)
//                            } placeholder: {
//                                ProgressView().frame(width: 150, height: 150)
//                            }
//                        }
//
//                        if user.profile.profileImagePath != nil {
//                            Button("Delete image") {
//                                viewModel.deleteProfileImage()
//                            }
//                        }
//                    }
                } else {
                    ProgressView("Loading profile...")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadCurrentUser()
                    } catch {
                        print("Error loading user in ProfileView: \(error.localizedDescription)")
                    }
                }
            }
            .onChange(of: selectedItem) { newValue in
                if let newValue {
                    viewModel.saveProfileImage(item: newValue)
                }
            }
            .navigationTitle("Profile")
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
