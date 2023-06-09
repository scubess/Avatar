
import UIKit
import Combine


protocol ListViewControllerDelegate: AnyObject {
    func sendUserDetail(data: GitUser)
}

class ListViewController: UICollectionViewController {

    // set up delegate, can use protocol to pass value (optionsl)
    weak var delegate: ListViewControllerDelegate?
    
    private var subscriptions = Set<AnyCancellable>()
        
    // MARK: - View Model
    private var viewModel = ListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //set up the callback to reload collectionview data
    func loadViewModel() {
      viewModel.fetchData()
    }
    
    func setupBindings() {
        viewModel.$avatarCellViewModels.sink { [weak self] error in
            //update the UI on the main thread
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }.store(in: &subscriptions)
    }

    //WHY VIEW WILL APPEAR ? View did load not enough ?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBindings()
        loadViewModel()

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.avatarCellViewModels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: AvatarCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AvatarCell
        let cellviewModel = viewModel.getCellViewModel(at: indexPath)
        cell.cellViewModel = cellviewModel
        return cell
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    private var insets: UIEdgeInsets { UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0) }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width - 2 * insets.left, height: 100)
    }

    //mark set up segue and push view controller 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        createSegueToDetailViewController(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func createSegueToDetailViewController(for indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else {
            return
        }
        guard let navigationController = navigationController else {
            return
        }
        let user = viewModel.avatarUsers[indexPath.row]
        controller.user = user
        navigationController.pushViewController(controller, animated: true)
    }
}
