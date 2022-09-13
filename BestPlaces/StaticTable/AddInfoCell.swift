

import Foundation
import UIKit

class AddInfoCell: UITableViewCell, UITextFieldDelegate {
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
       label.font = .boldSystemFont(ofSize: 16)
       return label
   }()

    let cellTextField: UITextField = {
       let textField = UITextField()
       textField.borderStyle = .roundedRect
       textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
       return textField
   }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .brown
        contentView.addSubview(cellLabel)
        contentView.addSubview(cellTextField)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(label: String, placeHolder: String) {
        cellLabel.text = label
        cellTextField.placeholder = placeHolder
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            cellTextField.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cellTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cellTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)

        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        cellTextField.resignFirstResponder()
    }
    
    
}
