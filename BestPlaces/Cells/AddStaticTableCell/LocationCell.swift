import UIKit

protocol LocationCellDelegate: AnyObject {
    func getAdress()
}

class LocationCell: UITableViewCell {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 14
            static let getAdressButtonWidthHeight: CGFloat = 22
            static let cellLabelToButtonIndentation: CGFloat = 8
        }
    }
    
    weak var delegate: LocationCellDelegate?
    
    static let cellID = "locationCellID"
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .italicSystemFont(ofSize: 20)
        return label
    }()
    
    let cellTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 18)
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var getAddressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "getAdressIcon"), for: .normal)
        button.addTarget(self, action: #selector(getAddressButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainConstants.tableViewBackgroundColor
        contentView.addSubview(cellLabel)
        contentView.addSubview(cellTextField)
        contentView.addSubview(getAddressButton)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func getAddressButtonTapped() {
        delegate?.getAdress()
    }
    
    func configure(label: String, placeHolder: String?) {
        cellLabel.text = label
        cellTextField.placeholder = placeHolder
    }
    
    func configure(label: String, text: String?) {
        cellLabel.text = label
        cellTextField.text = text
    }
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Constraints.sideIndentation),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Constraints.sideIndentation),
            cellLabel.trailingAnchor.constraint(equalTo: getAddressButton.leadingAnchor, constant: -Constants.Constraints.cellLabelToButtonIndentation)
        ])
        
        NSLayoutConstraint.activate([
            cellTextField.topAnchor.constraint(equalTo: cellLabel.bottomAnchor, constant: Constants.Constraints.sideIndentation),
            cellTextField.widthAnchor.constraint(equalTo: cellLabel.widthAnchor),
            cellTextField.centerXAnchor.constraint(equalTo: cellLabel.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            getAddressButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Constraints.sideIndentation),
            getAddressButton.widthAnchor.constraint(equalToConstant: Constants.Constraints.getAdressButtonWidthHeight),
            getAddressButton.heightAnchor.constraint(equalToConstant: Constants.Constraints.getAdressButtonWidthHeight),
            getAddressButton.centerYAnchor.constraint(equalTo: cellTextField.centerYAnchor)
        ])
    }
}
