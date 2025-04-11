//
//  ProfileViewModel.swift
//  Fit Pantry
//
//  Created by Chase Rodie on 2/5/25.

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: DBUser?
            
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let fetchedUser = try await UserManager.shared.getUserProfile(userId: authDataResult.uid)

            self.user = fetchedUser
    }

    
    func updateUserProfile(user: DBUser) async throws {
        try? await UserManager.shared.updateUserProfile(user: user)
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }

        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.metadata.userId)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.metadata.userId, path: path, url: url.absoluteString)
        }
    }
    
    func deleteProfileImage() {
        guard let user, let path = user.profile.profileImagePath else { return }

        Task {
            try await StorageManager.shared.deleteImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.metadata.userId, path: nil, url: nil)
        }
    }
}
