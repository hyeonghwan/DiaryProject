//
//  DiaryCell.swift
//  DiaryCell
//
//  Created by 박형환 on 2021/11/10.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet var diaryCellTitle: UILabel!
    @IBOutlet var diaryCellDate: UILabel!
  
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
    }
}
