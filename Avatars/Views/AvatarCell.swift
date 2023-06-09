
import UIKit

class AvatarCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!

    var cellViewModel: ListCellViewModel? {
        didSet {
            
            // login label text
            loginLabel.text = cellViewModel?.loginLabel
            
            //load image from image loader
            imageView.image = UIImage(systemName: "person")
            
            //Load image from Image loader
            ImageDownloader.loadImageAsync(stringURL: (cellViewModel?.imageURL)!) { image, error in
                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        self.imageView.image = UIImage(systemName: "person")
                        return
                    }
                    self.imageView.image = image
                }
            }
            
            // github label text
            githubLabel.text = cellViewModel?.githubLabel
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 5.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
    }
}
