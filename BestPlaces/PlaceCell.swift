import Foundation
import UIKit

class PlaceCell: UITableViewCell {
    
    static let placeCellId = "PlaceCellId"
        
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Text"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(label)
        contentView.addSubview(placeImageView)
    }
    
    func configure(textLabel: String, imageName: String) {
        label.text = textLabel
        placeImageView.image = UIImage(named: imageName)
    }
    
}

extension PlaceCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeImageView.topAnchor.constraint(equalTo: topAnchor),
            placeImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            placeImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
}
