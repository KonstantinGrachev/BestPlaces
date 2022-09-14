import Foundation
import UIKit

class AddViewController: UIViewController {
    
    let imageViewFromCell = AddImageCell()
    
    private var tableView: UITableView = {
        let tableView =  UITableView()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .secondarySystemBackground
        return tableView
    }()
    
    private var bottomAnchorScrollViewConstraint: NSLayoutConstraint?
    
     override func viewDidLoad() {
        super.viewDidLoad()
    
         setupViews()
         setDelegates()
         registerCell()
         setConstraints()
         registerForKeyboardNotifications()
         
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
    
    //MARK: - keyboard notification
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
        
    @objc override func handlePickedImage(_ image: UIImage) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageCell else { return }
        cell.cellImageView.image = image
        cell.cellImageView.contentMode = .scaleAspectFill
    }
    
}

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

extension AddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "From camera", style: .default) { [self] _ in
            showPicker(source: .camera)
        }
        
        let cameraIcon = UIImage(systemName: "camera")
        cameraAction.setValue(cameraIcon, forKey: "image")
        cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let photoLibraryAction = UIAlertAction(title: "From photos", style: .default) { [self] _ in
            showPicker(source: .photoLibrary)
        }
        let photoLibraryIcon = UIImage(systemName: "photo")
        photoLibraryAction.setValue(photoLibraryIcon, forKey: "image")
        photoLibraryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
        
    }
    
    func showPicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage = UIImage()
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        handlePickedImage(chosenImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePickedImage(_ image: UIImage) {
    }
}
