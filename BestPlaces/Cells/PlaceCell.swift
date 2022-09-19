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
    
    //MARK: - properties
    
    static let placeCellId = "PlaceCellId"
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    private var ratingStackView = UIStackView()
    private var ratingButtons = [UIButton]()
    private let countButtons = 5
    private var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
        
    //MARK: - UI

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "location"
        label.adjustsFontSizeToFitWidth = true
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
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - funcs
    
    private func setupViews() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(nameLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(placeImageView)
        setRatingStackView()
    }
    
    private func setRatingStackView() {
        ratingStackView = .createRatingStackView(buttonsArray: &ratingButtons,
                                                 countButtons: countButtons)
        contentView.addSubview(ratingStackView)
    }
    
    //MARK: - configure cell

    func configure(model: PlaceModel) {
        
        nameLabel.text = model.name
        locationLabel.text = model.location
        typeLabel.text = model.type
        rating = model.rating
        
        guard let imageData = model.imageData else { return }
        placeImageView.image = UIImage(data: imageData)
    }
}

//MARK: - constraints

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
            nameLabel.trailingAnchor.constraint(equalTo: ratingStackView.leadingAnchor, constant: Constants.Constraints.labelIndent)
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
        
        NSLayoutConstraint.activate([
            ratingStackView.widthAnchor.constraint(equalToConstant: 80),
            ratingStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Constraints.labelIndent)
        ])
    }
}

