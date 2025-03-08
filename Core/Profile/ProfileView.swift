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
                if viewModel.user != nil {
                    NavigationLink {
                        EditProfileView(viewModel: viewModel)
                    } label: {
                        Text("Edit Profile")
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Text("Select a photo")
                    }

                    if let urlString = viewModel.user?.profileImagePathUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView().frame(width: 150, height: 150)
                        }
                    }

                    if viewModel.user?.profileImagePath != nil {
                        Button("Delete image") {
                            viewModel.deleteProfileImage()
                        }
                    }
                }
            }
            .task {
                try? await viewModel.loadCurrentUser()
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
