//
//  AddCell.swift
//  BestPlaces
//
//  Created by Konstantin Gracheff on 13.09.2022.
//

import Foundation
import UIKit
class AddImageCell: UITableViewCell {
    
    enum Constants {
        enum Constraints {
            static let sideIndentation: CGFloat = 14
        }
    }
    
    static let cellID: String = "AddImageCell"
        
    let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loadPhoto")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainConstants.tableViewBackgroundColor
        contentView.addSubview(cellImageView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage) {
        cellImageView.image = image
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: topAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
    
}
