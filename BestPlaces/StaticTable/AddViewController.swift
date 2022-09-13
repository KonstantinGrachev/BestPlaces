//
//  addViewController.swift
//  BestPlaces
//
//  Created by Konstantin Gracheff on 13.09.2022.
//

import Foundation
import UIKit
class AddViewController: UIViewController {
    
    
    private var tableView: UITableView = {
        let tableView =  UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .gray
        return tableView
    }()
    
    private var bottomAnchorScrollViewConstraint: NSLayoutConstraint?
    
    let cellInfo = AddInfoCell()
    
     override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .systemRed
         setDelegates()
         view.addSubview(tableView)
         setConstraints()
         tableView.register(AddImageCell.self, forCellReuseIdentifier: AddImageCell.cellID)
         tableView.register(AddInfoCell.self, forCellReuseIdentifier: AddInfoCell.cellID)
         registerForKeyboardNotifications()
    }
    
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
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

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cellImage = tableView.dequeueReusableCell(withIdentifier: AddImageCell.cellID, for: indexPath) as? AddImageCell else { return UITableViewCell() }
            cellImage.configureCell()
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
            return view.frame.height / 2
        }
        return 85
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
