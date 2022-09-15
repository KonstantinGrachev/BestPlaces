import UIKit

protocol AddViewControllerDelegate: AnyObject {
    func addNewPlaceInModel(newPlace: PlaceModel?)
}

class AddViewController: UIViewController {
    
    weak var delegate: AddViewControllerDelegate?
        
    //MARK: - UI objects
    
    private var tableView: UITableView = {
        let tableView =  UITableView()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .secondarySystemBackground
        return tableView
    }()
    
    private var bottomAnchorScrollViewConstraint: NSLayoutConstraint?
    
    private var newPlace: PlaceModel?
    
    //MARK: - viewDidLoad
    
     override func viewDidLoad() {
        super.viewDidLoad()
         setNavigationController()
         setupViews()
         setDelegates()
         registerCell()
         registerForKeyboardNotifications()
         setConstraints()
         
    }
    
    //MARK: - settings view controller

    
    private func setNavigationController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false

    }
    
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func registerCell() {
        tableView.register(AddImageCell.self, forCellReuseIdentifier: AddImageCell.cellID)
        tableView.register(AddInfoCell.self, forCellReuseIdentifier: AddInfoCell.cellID)
    }
    
    private func setupViews() {
        view.backgroundColor = MainConstants.tableViewBackgroundColor
        view.addSubview(tableView)
    }
        
    //MARK: - pick image

    @objc override func handlePickedImage(_ image: UIImage) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageCell else { return }
        cell.cellImageView.image = image
        newPlace?.image = image
        cell.cellImageView.contentMode = .scaleAspectFill
    }
    
    //MARK: - navigation buttons

    @objc private func cancelButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
        saveNewPlaceModel()
    }
    
    //MARK: - all funcs
    
    private func saveNewPlaceModel() {
        guard let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageCell else { return }
        let image = imageCell.cellImageView.image
        
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AddInfoCell else { return }
        guard let name = nameCell.cellTextField.text else { return }
        
        guard let locationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? AddInfoCell else { return }
        let location = locationCell.cellTextField.text
        
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? AddInfoCell else { return }
        let type = typeCell.cellTextField.text
        
        newPlace = PlaceModel(name: name, location: location, type: type, image: image)
        
        delegate?.addNewPlaceInModel(newPlace: newPlace)
    }
    
}

//MARK: - table view

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cellImage = tableView.dequeueReusableCell(withIdentifier: AddImageCell.cellID, for: indexPath) as? AddImageCell else { return UITableViewCell() }
            
            return cellImage
            
        } else {
            let row = indexPath.row - 1
            guard let cellInfo = tableView.dequeueReusableCell(withIdentifier: AddInfoCell.cellID, for: indexPath) as? AddInfoCell else { return UITableViewCell() }
            cellInfo.configure(label: AddInfoCell.labelsText[row], placeHolder: AddInfoCell.placeHoldersText[row])
            cellInfo.cellTextField.delegate = self
            
            return cellInfo
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return view.frame.height / 3
        }
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            showActionSheet()
            hideKeyboard()
        } else {
            hideKeyboard()
        }
    }
}

//MARK: - keyboard

extension AddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - saveButton handler
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AddInfoCell else { return }
        guard let name = nameCell.cellTextField.text else { return }
        if name.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
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
}

//MARK: - constraints

extension AddViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        bottomAnchorScrollViewConstraint = NSLayoutConstraint(item: tableView,
                                                              attribute: .bottom,
                                                              relatedBy: .equal,
                                                              toItem: view,
                                                              attribute: .bottom,
                                                              multiplier: 1,
                                                              constant: 0)
        bottomAnchorScrollViewConstraint?.isActive = true
    }
}
