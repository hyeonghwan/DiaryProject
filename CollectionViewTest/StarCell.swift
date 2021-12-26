//
//  StarCell.swift
//  StarCell
//
//  Created by 박형환 on 2021/11/10.
//

import UIKit

class StarCell: UICollectionViewCell {
    
    @IBOutlet var titleCell: UILabel!
    @IBOutlet var dateCell: UILabel!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        
    }
}
