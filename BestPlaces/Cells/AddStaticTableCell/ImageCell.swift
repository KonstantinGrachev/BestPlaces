import UIKit

protocol ImageCellDelegate: AnyObject {
    func openMap()
}

class ImageCell: UITableViewCell {
    
    weak var delegate: ImageCellDelegate?
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 14
            static let mapButtonWidthHeight: CGFloat = 44
            static let mapButtonCornerRadius: CGFloat = mapButtonWidthHeight / 2
        }
    }
    
    static let cellID: String = "AddImageCell"
        
    let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loadPhoto")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var mapButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mapIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.Constraints.mapButtonCornerRadius
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainConstants.tableViewBackgroundColor
        contentView.addSubview(cellImageView)
        contentView.addSubview(mapButton)
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - @IBAction funcs

    @IBAction private func mapButtonTapped() {
        delegate?.openMap()
    }
    
    //MARK: - configure cell
    
    func configureCell(image: UIImage?) {
        cellImageView.image = image
    }
    
    //MARK: - set constraints

    func setConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: topAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            mapButton.widthAnchor.constraint(equalToConstant: Constants.Constraints.mapButtonWidthHeight),
            mapButton.heightAnchor.constraint(equalToConstant: Constants.Constraints.mapButtonWidthHeight),
            mapButton.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -Constants.Constraints.sideIndentation),
            mapButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: -Constants.Constraints.sideIndentation)
        ])
        
    }
    
}
