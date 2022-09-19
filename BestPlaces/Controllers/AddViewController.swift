import UIKit

protocol AddViewControllerDelegate: AnyObject {
    func addNewPlaceInModel(newPlace: PlaceModel?)
}

class AddViewController: UIViewController {
    
    weak var delegate: AddViewControllerDelegate?
    
    var currentPlace: PlaceModel?
    
    //MARK: - UI objects
    
    let tableView: UITableView = {
        let tableView =  UITableView()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .secondarySystemBackground
        return tableView
    }()
    
    private var imageIsChange = false
    private var bottomAnchorScrollViewConstraint: NSLayoutConstraint?
        
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
        tableView.register(CustomRatingCell.self, forCellReuseIdentifier: CustomRatingCell.cellID)
    }
    
    private func setupViews() {
        view.backgroundColor = MainConstants.tableViewBackgroundColor
        view.addSubview(tableView)
    }
        
    //MARK: - pick image

    @objc override func handlePickedImage(_ image: UIImage) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageCell else { return }
        cell.cellImageView.image = image
        cell.cellImageView.contentMode = .scaleAspectFill
        imageIsChange = true
    }
    
    //MARK: - navigation buttons

    @objc private func cancelButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
        savePlaceModel()
    }
    
    //MARK: - save model
    
    private func savePlaceModel() {
        guard let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageCell else { return }
        var image: UIImage?
        if imageIsChange {
            image = imageCell.cellImageView.image
        } else {
            image = MainConstants.plainPlaceImage
        }
        let imageData = image?.pngData()
        
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AddInfoCell else { return }
        guard let name = nameCell.cellTextField.text else { return }
        
        guard let locationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? AddInfoCell else { return }
        let location = locationCell.cellTextField.text
        
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? AddInfoCell else { return }
        let type = typeCell.cellTextField.text
        
        guard let ratingCell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? CustomRatingCell else { return }
        let rating = ratingCell.rating
        
        let newPlace = PlaceModel.init(name: name,
                                       location: location,
                                       type: type,
                                       imageData: imageData,
                                       rating: rating)
        
        if currentPlace != nil {
            try! realm.write({
                currentPlace?.name = name
                currentPlace?.location = location
                currentPlace?.type = type
                currentPlace?.imageData = imageData
                currentPlace?.rating = rating
                
                delegate?.addNewPlaceInModel(newPlace: currentPlace)
            })
            
        } else {
            StorageManager.addNewPlaces(newPlace)
            delegate?.addNewPlaceInModel(newPlace: newPlace)
        }
        
        
    }
}

//MARK: - table view

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let imageCell = tableView.dequeueReusableCell(withIdentifier: AddImageCell.cellID, for: indexPath) as? AddImageCell else { return UITableViewCell() }
            transferCurrentPlaceImage(imageCell: imageCell)
            return imageCell
            
        } else if 1...3 ~= indexPath.row {
            let row = indexPath.row - 1
            guard let infoCell = tableView.dequeueReusableCell(withIdentifier: AddInfoCell.cellID, for: indexPath) as? AddInfoCell else { return UITableViewCell() }
            infoCell.cellTextField.delegate = self
            transferCurrentPlaceData(infoCell: infoCell, row: row)
            return infoCell
            
        } else {
            guard let ratingCell = tableView.dequeueReusableCell(withIdentifier: CustomRatingCell.cellID, for: indexPath) as? CustomRatingCell else { return UITableViewCell() }
            transferCurrentPlaceRating(ratingCell: ratingCell)
            return ratingCell
        } 

    }
    
    //MARK: if controller open for editing
    
    func transferCurrentPlaceData(infoCell: AddInfoCell, row: Int) {
        if currentPlace != nil {

            imageIsChange = true
            navigationItem.rightBarButtonItem?.isEnabled = true
            
            let textLabel = AddInfoCell.labelsText[row]
            let defaultTextPlaceholder = AddInfoCell.placeHoldersText[row]
            
            let name = currentPlace?.name
            let location = currentPlace?.location
            let type = currentPlace?.type
            
            switch row {
            case 0:
                infoCell.configure(label: textLabel, text: name)
            case 1:
                if location != "" {
                    infoCell.configure(label: textLabel, text: location)
                } else {
                    infoCell.configure(label: textLabel, placeHolder: defaultTextPlaceholder)
                }
            case 2:
                if type != "" {
                    infoCell.configure(label: textLabel, text: type)
                } else {
                    infoCell.configure(label: textLabel, placeHolder: defaultTextPlaceholder)
                }
            default: break
            }
        } else {
            switch row {
            case 0...2:
                infoCell.configure(label: AddInfoCell.labelsText[row], placeHolder: AddInfoCell.placeHoldersText[row])
            default: break
            }
            
        }
    }
    
    func transferCurrentPlaceImage(imageCell: AddImageCell) {
        if currentPlace != nil {
            guard let imageData = currentPlace?.imageData else { return }
            let image = UIImage(data: imageData)
            imageCell.configureCell(image: image)
            imageCell.cellImageView.contentMode = .scaleAspectFill
        }
    }
    
    func transferCurrentPlaceRating(ratingCell: CustomRatingCell) {
        if currentPlace != nil {
            guard let rating = currentPlace?.rating else { return }
            ratingCell.rating = rating
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
    
    //MARK: - saveButton handler textField
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AddInfoCell else { return }
        guard let name = nameCell.cellTextField.text else { return }
        if name.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
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
