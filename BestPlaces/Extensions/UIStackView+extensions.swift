import UIKit

extension UIStackView {
    //MARK: - without actions
    static func createRatingStackView(buttonsArray: inout [UIButton], countButtons: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: - create buttons
        for _ in 0..<countButtons {
            lazy var starButton: UIButton = {
                let button = UIButton()
                button.setImage(UIImage(systemName: "star"), for: .normal)
                button.setImage(UIImage(systemName: "star.fill"), for: .selected)
                button.tintColor = .systemCyan
                button.imageView?.contentMode = .scaleAspectFit
                button.isUserInteractionEnabled = false
                button.translatesAutoresizingMaskIntoConstraints = false
                return button
            }()
            stackView.addArrangedSubview(starButton)
            buttonsArray.append(starButton)
        }
        
        return stackView
    }
    
    //MARK: - with actions

    static func createRatingStackView(buttonsArray: inout [UIButton],
                                      countButtons: Int,
                                      target: Any,
                                      action: Selector) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: - create buttons
        for _ in 0..<countButtons {
            lazy var starButton: UIButton = {
                let button = UIButton()
                button.setImage(UIImage(systemName: "star"), for: .normal)
                button.setImage(UIImage(systemName: "star.fill"), for: .selected)
                button.addTarget(target, action: action, for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false
                return button
            }()
            stackView.addArrangedSubview(starButton)
            buttonsArray.append(starButton)
        }
        
        return stackView
    }
}
