// ListViewModel.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import Combine
import UIKit

// Tell Listview(should be tableview?) to Reload the collectionView-tableview
protocol ListViewModelDelegate: AnyObject {
    func reloadData()
}

class ListViewModel: ObservableObject {
    weak var delegate: ListViewModelDelegate?
    
    private var subscriptions = Set<AnyCancellable>()
    
    var avatarAPI = NetworkManager.shared
    
    @Published var avatarCellViewModels: [ListCellViewModel] = []
    
    var avatarUsers : [GitUser] = []
    
    //MARK: -  Fetch data
    func fetchData() {
        avatarAPI.FetchData(from: Constants.baseURL + Endpoint.users.rawValue)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error)
                }
            }
    receiveValue: { [unowned self] in
        avatarUsers = $0
        self.avatarCellViewModels = self.createCellViewModels(from: avatarUsers)
    }
    .store(in: &self.subscriptions)
    }
    
    //MARK: - Helper Methods
    // Create CellViewModels from the data response
    func createCellViewModels(from resultsArray: [GitUser]) -> [ListCellViewModel] {
        
        var viewModels: [ListCellViewModel] = []
        
        for result in resultsArray {
            
            let cellViewModel = buildCellModel(from: result)
            viewModels.append(cellViewModel)
        }

//        viewModels.sort {
//            $0.loginLabel ?? "" < $1.loginLabel ?? ""
//        }
        
        return viewModels
    }
    
    func reloadData() {
        self.delegate?.reloadData()
    }
    
    // Build a single CellViewModel
    func buildCellModel(from user: GitUser) -> ListCellViewModel {
        return ListCellViewModel(imageURL: user.avatar_url, loginLabel: user.login, githubLabel: user.html_url)
    }
    
    
    // Return a CellViewModel for the current IndexPath
    func getCellViewModel(at indexPath: IndexPath) -> ListCellViewModel {
        return avatarCellViewModels[indexPath.row]
    }
        
    // MARK: - Handle errors
    func handleError(_ apiError: NetworkServiceError) {
        print("ERROR: \(apiError.localizedDescription)!!!!!")
    }
}
