import UIKit

protocol NewPlaceViewControllerDelegate: AnyObject {
    func reloadHomeTableView()
}

class NewPlaceViewController: UIViewController {
    
    weak var delegate: NewPlaceViewControllerDelegate?
    
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
    
    //MARK: - set delegates

    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func registerCell() {
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.cellID)
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.cellID)
        tableView.register(RatingCell.self, forCellReuseIdentifier: RatingCell.cellID)
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.cellID)
    }
    
    private func setupViews() {
        view.backgroundColor = MainConstants.tableViewBackgroundColor
        view.addSubview(tableView)
    }
        
    //MARK: - pick image

    @objc override func handlePickedImage(_ image: UIImage) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageCell else { return }
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
        guard let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageCell else { return }
        
        var image = imageIsChange ? imageCell.cellImageView.image : nil
        
        var imageData = image?.pngData()
        
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InfoCell else { return }
        guard let name = nameCell.cellTextField.text else { return }
        
        guard let locationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? LocationCell else { return }
        let location = locationCell.cellTextField.text
        
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? InfoCell else { return }
        let type = typeCell.cellTextField.text
        
        guard let ratingCell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? RatingCell else { return }
        let rating = ratingCell.rating
        
        let newPlace = PlaceModel.init(name: name,
                                       location: location,
                                       type: type,
                                       imageData: imageData,
                                       rating: rating)
        
        if currentPlace != nil {
            if image == MainConstants.loadPhotoImage {
                image = nil
                imageData = image?.pngData()
            }
            try! realm.write({
                currentPlace?.name = name
                currentPlace?.location = location
                currentPlace?.type = type
                currentPlace?.imageData = imageData
                currentPlace?.rating = rating
                
                delegate?.reloadHomeTableView()
            })
            
        } else {
            StorageManager.addNewPlaces(newPlace)
            delegate?.reloadHomeTableView()
        }
    }
}

//MARK: - table view

extension NewPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageCell.cellID, for: indexPath) as? ImageCell else { return UITableViewCell() }
                        transferCurrentPlaceImage(imageCell: imageCell)
                        imageCell.delegate = self
                        return imageCell
        
        case 1, 3:
            let row = indexPath.row - 1
                        guard let infoCell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellID, for: indexPath) as? InfoCell else { return UITableViewCell() }
                        infoCell.cellTextField.delegate = self
                        transferCurrentPlaceNameAndType(infoCell: infoCell, row: row)
                        return infoCell
        case 2:
                        guard let locationCell = tableView.dequeueReusableCell(withIdentifier: LocationCell.cellID, for: indexPath) as? LocationCell else { return UITableViewCell() }
                        locationCell.delegate = self
                        transferCurrentPlaceLocation(locationCell: locationCell)
                        return locationCell
            
        case 4:
                        guard let ratingCell = tableView.dequeueReusableCell(withIdentifier: RatingCell.cellID, for: indexPath) as? RatingCell else { return UITableViewCell() }
                        transferCurrentPlaceRating(ratingCell: ratingCell)
                        return ratingCell
        default:
            return UITableViewCell()
        }
    }
    
    //MARK: if controller open for editing
    
    func transferCurrentPlaceNameAndType(infoCell: InfoCell, row: Int) {
        if currentPlace != nil {

            imageIsChange = true
            navigationItem.rightBarButtonItem?.isEnabled = true
            
            let textLabel = InfoCell.labelsText[row]
            let defaultTextPlaceholder = InfoCell.placeHoldersText[row]
            
            let name = currentPlace?.name
            let type = currentPlace?.type
            
            switch row {
            case 0:
                infoCell.configure(label: textLabel, text: name)
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
            case 0, 2:
                infoCell.configure(label: InfoCell.labelsText[row], placeHolder: InfoCell.placeHoldersText[row])
            default: break
            }
        }
    }
    
    func transferCurrentPlaceLocation(locationCell: LocationCell) {
        if currentPlace != nil {
            
            let location = currentPlace?.location
            
            if location != "" {
                locationCell.configure(label: "Location", text: location)
            } else {
                locationCell.configure(label: "Location", placeHolder: "Enter address")
            }
    
        } else {
            locationCell.configure(label: "Location", placeHolder: "Enter address")
        }
    }
    
    func transferCurrentPlaceImage(imageCell: ImageCell) {
        if currentPlace != nil {
            guard let imageData = currentPlace?.imageData else { return }
            let image = UIImage(data: imageData)
            imageCell.configureCell(image: image)
            imageCell.cellImageView.contentMode = .scaleAspectFill
        }
    }
    
    func transferCurrentPlaceRating(ratingCell: RatingCell) {
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

extension NewPlaceViewController: UITextFieldDelegate {
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
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InfoCell else { return }
        guard let name = nameCell.cellTextField.text else { return }
        if name.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

}

//MARK: - constraints

extension NewPlaceViewController {
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

//MARK: - ImageCellDelegate

extension NewPlaceViewController: ImageCellDelegate {
    func openMap() {
        let mapController = MapViewController()
        
        let placeMap = PlaceModel()
        
        if let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageCell {
            if let imageData = imageCell.cellImageView.image?.pngData() {
                placeMap.imageData = imageData
            }
        }
        
        if let nameCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InfoCell {
            if let name = nameCell.cellTextField.text {
                placeMap.name = name
            }
        }
        
        if let locationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? LocationCell {
            if let location = locationCell.cellTextField.text {
                placeMap.location = location
            }
        }
        
        if let typeCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? InfoCell {
            if let type = typeCell.cellTextField.text {
                placeMap.type = type
            }
        }
        mapController.place = placeMap
        navigationController?.pushViewController(mapController, animated: true)
    }
}

//MARK: - LocationCellDelegate
extension NewPlaceViewController: LocationCellDelegate {
    func getAdress() {
        let mapViewController = MapViewController()
        mapViewController.isGetAddress = true
        mapViewController.delegate = self
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}

//MARK: - MapViewControllerDelegate

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(address text: String) {
        guard let locationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? LocationCell else { return }
        locationCell.cellTextField.text = text
    }
}
