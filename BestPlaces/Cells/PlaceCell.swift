import UIKit

class PlaceCell: UITableViewCell {
    
    enum Constants {
        enum Constraints {
            static let imageViewIndent: CGFloat = 10
            static let widthImageView: CGFloat = 65
            static let leadingImageView: CGFloat = 16
            static let labelIndent: CGFloat = 10
            static let cornerRadiusImageView: CGFloat = widthImageView / 2
        }
    }
    
    static let placeCellId = "PlaceCellId"
        
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "location"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "type"
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "plainPlace")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.Constraints.cornerRadiusImageView
        imageView.clipsToBounds = true
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
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(nameLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(placeImageView)
    }
    
    func configure(model: PlaceModel) {
        
        
        nameLabel.text = model.name
        locationLabel.text = model.location
        typeLabel.text = model.type
        
        guard let imageData = model.imageData else { return }
        placeImageView.image = UIImage(data: imageData)
    }
}

extension PlaceCell {
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Constraints.leadingImageView),
            placeImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Constraints.imageViewIndent),
            placeImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Constraints.imageViewIndent),
            placeImageView.widthAnchor.constraint(equalToConstant: Constants.Constraints.widthImageView)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: placeImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: Constants.Constraints.labelIndent),
            nameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: Constants.Constraints.labelIndent)
        ])
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: typeLabel.topAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            typeLabel.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor),
            typeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
}

