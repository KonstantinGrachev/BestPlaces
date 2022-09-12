import UIKit

class AddPlaceViewController: UIViewController {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 14
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .secondarySystemBackground
        scrollView.bounces = false
        return scrollView
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loadPhoto")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.placeholder = "Enter place's name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter location"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Type"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter type"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var nameStackView = UIStackView()
    private var locationStackView = UIStackView()
    private var typeStackView = UIStackView()
    
    private var bottomAnchorScrollViewConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        registerForKeyboardNotifications()
    }
    
    private func setDelegates() {
        nameTextField.delegate = self
        locationTextField.delegate = self
        typeTextField.delegate = self
    }
    
    private func setupViews() {
        navigationItem.title = "Add place"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(backgroundView)
        backgroundView.addSubview(imageView)
        setupStackViews()
        setDelegates()
        
    }
    
    private func setupStackViews() {
        nameStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField],
                                    axis: .vertical,
                                    spacing: 8)
        backgroundView.addSubview(nameStackView)
        
        locationStackView = UIStackView(arrangedSubviews: [locationLabel, locationTextField],
                                    axis: .vertical,
                                    spacing: 8)
        backgroundView.addSubview(locationStackView)
        
        typeStackView = UIStackView(arrangedSubviews: [typeLabel, typeTextField],
                                    axis: .vertical,
                                    spacing: 8)
        backgroundView.addSubview(typeStackView)
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @IBAction private func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomAnchorScrollViewConstraint?.constant = keyboardScreenEndFrame.height
        } else {
            bottomAnchorScrollViewConstraint?.constant = -keyboardScreenEndFrame.height - 10
        }
        
        view.needsUpdateConstraints()
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func cancelButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension AddPlaceViewController {
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        
        bottomAnchorScrollViewConstraint = NSLayoutConstraint(item: scrollView,
                                                              attribute: .bottom,
                                                              relatedBy: .equal,
                                                              toItem: view,
                                                              attribute: .bottom,
                                                              multiplier: 1,
                                                              constant: 0)
        bottomAnchorScrollViewConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor),
            backgroundView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constants.Constraints.sideIndentation),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Constraints.sideIndentation),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Constraints.sideIndentation),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        NSLayoutConstraint.activate([
            nameStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.Constraints.sideIndentation),
            nameStackView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            nameStackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            locationStackView.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: Constants.Constraints.sideIndentation),
            locationStackView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            locationStackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            typeStackView.topAnchor.constraint(equalTo: locationStackView.bottomAnchor, constant: Constants.Constraints.sideIndentation),
            typeStackView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            typeStackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
    }
}

extension AddPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        nameTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        typeTextField.resignFirstResponder()
    }
}
