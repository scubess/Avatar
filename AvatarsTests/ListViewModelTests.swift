// ImageTests.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import XCTest
@testable import Avatars

final class ImageTests: XCTestCase {

    var sut: ListViewModel!
    var users: [GitUser]!

    // MARK: - Setup Methods
    override func setUpWithError() throws {
        try super.setUpWithError()
      
        sut = ListViewModel()
        createUserarray()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        users = nil
      
      try super.tearDownWithError()
    }

    //MARK: - support methods
    func createUserarray() {
        users = [
            GitUser(
                login: "mojombo",
                id: 1,
                avatar_url: "https://avatars.githubusercontent.com/u/1?v=4",
                url: "https://api.github.com/users/mojombo",
                repos_url: "https://api.github.com/users/mojombo/repos",
                html_url: "https://github.com/mojombo",
                followers_url: "https://api.github.com/users/mojombo/following"),
            GitUser(
                login: "defunkt",
                id: 2,
                avatar_url: "https://avatars.githubusercontent.com/u/2?v=4",
                url: "https://api.github.com/users/defunkt",
                repos_url: "https://api.github.com/users/defunkt/repos",
                html_url: "https://github.com/defunkt",
                followers_url: "https://api.github.com/users/defunkt/followers"),
            GitUser(
                login: "pjhyett",
                id: 3,
                avatar_url: "https://avatars.githubusercontent.com/u/3?v=4",
                url: "https://api.github.com/users/pjhyett",
                repos_url: "https://api.github.com/users/pjhyett/repos",
                html_url: "https://github.com/pjhyett",
                followers_url: "https://api.github.com/users/pjhyett/following"),
            GitUser(
                login: "wycats",
                id: 4,
                avatar_url: "https://avatars.githubusercontent.com/u/4?v=4",
                url: "https://api.github.com/users/wycats",
                repos_url: "https://api.github.com/users/wycats/repos",
                html_url: "https://github.com/wycats",
                followers_url: "https://api.github.com/users/wycats/following"),
        ]
    }
    
    //MARK: - helper methods
    func createCellModel(from user: GitUser) -> ListCellViewModel {
        return ListCellViewModel(
            imageURL: user.avatar_url, loginLabel: user.login, githubLabel: user.html_url)
    }

    func createCellViewModelArray() -> [ListCellViewModel] {
      var viewModels: [ListCellViewModel] = []
      
      for user in users {
        let viewModel = ListCellViewModel(
            imageURL: user.avatar_url, loginLabel: user.login, githubLabel: user.html_url)
        viewModels.append(viewModel)
      }
        
      return viewModels
    }
    
    // MARK: - Build Single Cell View Model
    func testBuildCellModel_whenUserModelGiven() {
      // given
      let user = users[0]
      let expectedViewModel = createCellModel(from: user)
      
      // when
      let viewModel = sut.buildCellModel(from: user)
      
      // then
      XCTAssertEqual(viewModel, expectedViewModel)
    }


    // MARK: - Create Cell View Model Array
    func testCreateCellViewModels_whenUserArrayGiven() {
      // given
      let expectedViewModelArray = createCellViewModelArray()
      
      // when
      let viewModels = sut.createCellViewModels(from: users)
      
      // then
      XCTAssertEqual(viewModels, expectedViewModelArray)
    }


    // MARK: - Get Cell View Model
    func testGetCellViewModel_givenIndexPath() {
      // given
      let indexPath = IndexPath(row: 1, section: 1)
      let expectedViewModel = createCellViewModelArray()[indexPath.row]

      // when
      let viewModels = sut.createCellViewModels(from: users)
      sut.avatarCellViewModels = viewModels
      let viewModel = sut.getCellViewModel(at: indexPath)

      // then
      XCTAssertEqual(viewModel, expectedViewModel)
    }

}
