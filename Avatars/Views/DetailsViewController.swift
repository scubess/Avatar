
import UIKit
import Combine

protocol DetailsViewControllerDelegate: AnyObject {
    func reloadData()
}

class DetailsViewController: UIViewController {
    
    //replace collection view into a tableview
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    @IBOutlet weak private var githubLabel: UILabel!
    @IBOutlet weak private var detailsStackView: UIStackView!
    
    var activityIndicator:UIActivityIndicatorView!
    
    //Get current user from previous view controller
    var user : GitUser?
    
    var detailViewModel = DetailViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var controller: UIViewController!
    
    var detailLabels = [UILabel]() {
        didSet {
            setupViews()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadViewModel()
        setupBindings()
    }
    
    
    func setupViews() {
        usernameLabel.text = user?.login
        guard let html_url = user?.html_url else {
            return
        }
        
        guard let avatar_url = user?.avatar_url else {
            return
        }
        
        // Image Loader, can be loaded into Viewmodel
        ImageDownloader.loadImageAsync(stringURL: avatar_url) { image, error in
            DispatchQueue.main.async {
                
                guard error == nil else {
                    self.imageView.image = UIImage(systemName: "person")
                    return
                }
                self.imageView.image = image
            }
        }
        
        githubLabel.text = "GitHub:\n\(html_url)"
        
        detailLabels.forEach { label in
            detailsStackView.addArrangedSubview(label)
        }
    }
    
    //set up the callback to reload collectionview data
    func loadViewModel() {
        detailViewModel.fetchData(user: user)
    }
    //set up bindings to keep consistency all over
    func setupBindings() {
        // Followers
        detailViewModel.$followersCount.sink { [weak self] _ in
            DispatchQueue.main.async {
                guard self!.detailViewModel.followersCount != 0 else {
                    return
                }
                self?.detailLabels.append(self!.makeLabel(text: "Followers count: \(self!.detailViewModel.followersCount)"))
            }
        }.store(in: &subscriptions)
        
        // Following
        detailViewModel.$followingCount.sink { [weak self] _ in
            DispatchQueue.main.async {
                guard self!.detailViewModel.followingCount != 0 else {
                    return
                }
                self?.detailLabels.append(self!.makeLabel(text: "Following count: \(self!.detailViewModel.followersCount)"))
            }
        }.store(in: &subscriptions)
        
        // repo count
        detailViewModel.$repoCount.sink { [weak self] _ in
            DispatchQueue.main.async {
                guard self!.detailViewModel.repoCount != 0 else {
                    return
                }
                self?.detailLabels.append(self!.makeLabel(text: "Repo count: \(self!.detailViewModel.repoCount)"))
                
            }
        }.store(in: &subscriptions)
        
        // Gist
        detailViewModel.$GistCount.sink { [weak self] _ in
            DispatchQueue.main.async {
                guard self!.detailViewModel.GistCount != 0 else {
                    return
                }
                self?.detailLabels.append(self!.makeLabel(text: "Gists count: \(self!.detailViewModel.GistCount)"))
            }
        }.store(in: &subscriptions)
    }
    
    func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }
}
