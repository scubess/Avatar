
import UIKit

class ImageDownloader {
    
    private enum Constants {
        static let endpoint = "https://i.pravatar.cc"
    }
    
    static func downloadAvatar(avatarID: String, size: Int, completion: @escaping (Result<UIImage, Error>) -> Void) {
        var components = URLComponents(string: Constants.endpoint + "/" + "\(size)")
        components?.queryItems = [
            URLQueryItem(name: "img", value: avatarID)
        ]
        guard let imageUrl = components?.url else { return }

        let request = URLRequest(url: imageUrl)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error as NSError? {
                completion(.failure(error))
            } else if let data, let image = UIImage(data: data) {
                completion(.success(image))
            }
        }
        dataTask.resume()
    }
    
    static func loadImageAsync(stringURL: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        let group = DispatchGroup()
        group.enter()
        let url = URL(string: stringURL)!

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async { completion(image, nil) }
            group.leave()
        }.resume()
    }

    
}
