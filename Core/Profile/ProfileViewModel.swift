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
        let fetchedUser = try await UserManager.shared.getUser(userId: authDataResult.uid)

        DispatchQueue.main.async {
            self.user = fetchedUser
            print("User loaded: \(String(describing: self.user))") 
        }
    }

    
    func updateUserProfile(user: DBUser) async throws {
        try? await UserManager.shared.updateUserProfile(user: user)
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
            
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }

        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("SUCCESS!")
            print(path)
            print(name)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
        }
    }
    
    func deleteProfileImage() {
        guard let user, let path = user.profileImagePath else { return }

        Task {
            try await StorageManager.shared.deleteImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
        }
    }
    
    func getWeightHistory() -> [(date: Date, weight: String)] {
        return user?.weightHistory ?? []
    }
    
    func getWeightChange() -> String {
        guard let history = user?.weightHistory, history.count > 1 else {
            return "No weight data available"
        }
        
        let latest = history.last!
        let previous = history[history.count - 2]
        
        if let latestWeight = Double(latest.weight), let previousWeight = Double(previous.weight) {
            let difference = latestWeight - previousWeight
            if difference == 0 {
                return "No change in weight"
            } else if difference > 0 {
                return "Gained \(String(format: "%.1f", difference)) lbs"
            } else {
                return "Lost \(String(format: "%.1f", abs(difference))) lbs"
            }
        }
        
        return "Invalid weight data"
    }
}
