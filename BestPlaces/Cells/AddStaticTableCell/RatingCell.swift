import UIKit

class RatingCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let cellID = "customRatingCellID"
    
    private var stackView = UIStackView()
    
    private var ratingButtons = [UIButton]()
    
    private let countButtons = 5
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        setStackView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func ratingButtonTapped(_ button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        let selectedRating = index + 1
        rating = selectedRating == rating ? 0 : selectedRating
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    private func setStackView() {
        stackView = .createRatingStackView(buttonsArray: &ratingButtons, countButtons: countButtons, target: self, action: #selector(ratingButtonTapped(_:)))
        contentView.addSubview(stackView)
        updateButtonSelectionStates()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: MainConstants.sideIndentation * 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -MainConstants.sideIndentation * 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
}
