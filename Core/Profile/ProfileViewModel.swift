//
//  SwiftUIView.swift
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
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func updateUserProfile(user: DBUser) async throws {
        try? await UserManager.shared.updateUserProfile(user: user)
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
//    func addUserInformation(text: String) {
//        guard let user else { return }
//
//        Task {
//            try await UserManager.shared.addUserInformation(userId: user.userId, userInformation: text)
//            self.user = try await UserManager.shared.getUser(userId: user.userId)
//        }
//    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    //func updateProfile(weight: String, height: String, gender: String, age: Int, fitnessLevel: String, goal: String) {
        //guard let userId = user?.userId else { return }
        
        //Task {
            //do {
                //try await UserManager.shared.updateUserProfile(userId: userId, weight: weight, height: height, gender: gender, age: age, fitnessLevel: fitnessLevel, goal: goal)
                //DispatchQueue.main.async {
                    
                //}
            //}
        //}
    //}
            
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
    
}
