// DetailsViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import Combine
import UIKit

class DetailViewModel: ObservableObject {
    

//    let user: GitUser?
                
    var avatarAPI = NetworkManager.shared
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var repoCount: Int = 0
    @Published var GistCount: Int = 0

    //MARK: Fetch Data
    func loadImage(from url: String) -> UIImage {
        return UIImage(systemName: "person")!
    }
    
    func fetchData(user: GitUser?) {
        guard let user = user else {
            return
        }
                
        let dispatchGroup = DispatchGroup()
        
        // Followers
        dispatchGroup.enter()
        avatarAPI.FetchData(from: user.followers_url) .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error)
                }
            }
            receiveValue: { [unowned self] in
                let followers: [Followers] = $0
                DispatchQueue.main.async {
                    self.followersCount = followers.count
                }
                dispatchGroup.leave()
            }
            .store(in: &self.subscriptions)

        // Following
        dispatchGroup.enter()
        avatarAPI.FetchData(from: user.following_url) .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error)
                }
            }
            receiveValue: { [unowned self] in
                let following: [Following] = $0
                DispatchQueue.main.async {
                    self.followingCount = following.count
                }
                dispatchGroup.leave()
            }
            .store(in: &self.subscriptions)

        // Repos
        dispatchGroup.enter()
        avatarAPI.FetchData(from: user.repos_url) .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error)
                }
            }
            receiveValue: { [unowned self] in
                let repo: [Repo] = $0
                DispatchQueue.main.async {
                    self.repoCount = repo.count
                }
                dispatchGroup.leave()
            }
            .store(in: &self.subscriptions)

        // Gists
        dispatchGroup.enter()
        avatarAPI.FetchData(from: user.gists_url) .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error)
                }
            }
            receiveValue: { [unowned self] in
                let gist: [Gist] = $0
                DispatchQueue.main.async {
                    self.GistCount = gist.count
                }
                dispatchGroup.leave()
            }
            .store(in: &self.subscriptions)
        
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: AvatarServiceError) {
        print("ERROR: \(apiError.localizedDescription)!!!!!")
    }
}
