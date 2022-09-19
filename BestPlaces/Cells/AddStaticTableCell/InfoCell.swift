import UIKit

class InfoCell: UITableViewCell {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 14
        }
    }
    
    static let cellID = "AddInfoCell"
    
    static let labelsText = ["Name",
                      "Location",
                      "Type"]
    
    static let placeHoldersText = ["Type place's name",
                            "Type location",
                            "Enter type"
    ]
    
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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainConstants.tableViewBackgroundColor
        contentView.addSubview(cellLabel)
        contentView.addSubview(cellTextField)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Constraints.sideIndentation)
        ])
        
        NSLayoutConstraint.activate([
            cellTextField.topAnchor.constraint(equalTo: cellLabel.bottomAnchor, constant: Constants.Constraints.sideIndentation),
            cellTextField.widthAnchor.constraint(equalTo: cellLabel.widthAnchor),
            cellTextField.centerXAnchor.constraint(equalTo: cellLabel.centerXAnchor)
        ])
    }
}
