// NetworkManager.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import Combine
import UIKit

//MARK:- Combine 
class NetworkManager: NetworkService {
    

    //MARK: - properties
    static let shared = NetworkManager()
    private let urlSession  = URLSession.shared
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK- decoder
    private let jsonDecoder: JSONDecoder  = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
    
    //MARK:- Init
    private init() { }
    
    func FetchData<T>(from urlString: String) -> Future<T, NetworkServiceError> where T : Decodable, T : Encodable {
        //Initialise and retturn future
        return Future<T, NetworkServiceError> { [unowned self] promise in
            guard let url = self.createURL(with: urlString) else {
                return promise(.failure(.urlError(URLError(.unsupportedURL))))
            }
            
            // Start fetch data
            self.urlSession.dataTaskPublisher(for: url)
            
            // even check the response status code between 200 ... 299 ?
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode
                    else {
                        throw NetworkServiceError.responseError((response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
                }
            //Decode the published JSON into Users Model
                .decode(type: T.self, decoder: self.jsonDecoder)
            
            // Make sure the completion run on main thread
                .receive(on: RunLoop.main)
            
            // subscribe to receive value
                .sink { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let urlError as URLError:
                            promise(.failure(.urlError(urlError)))
                        case let decodingError as DecodingError:
                            promise(.failure(.decodingError(decodingError)))
                        case let apiError as NetworkServiceError:
                          promise(.failure(apiError))
                        default:
                          promise(.failure(.anyError))

                        }
                    }
                }
                receiveValue: {
                    promise(.success($0))
                }
                //Make sure the subscription still works after receive
                .store(in: &self .subscriptions)
        }
    }
    
    private func createURL(with urlString: String) -> URL? {
        guard let urlComponents = URLComponents(string: "\(urlString)") else {
            return nil
        }
        return urlComponents.url
    }
}
