//
//  ShortDescription.swift
//  ASCStatus8.0
//
//  Created by Nazim Siddiqui on 29/01/16.
//  Copyright © 2016 Kratin. All rights reserved.
//

import UIKit

class ShortDescription: UITableViewCell {
    
    
//    @IBOutlet var imageLabel: UIButton!
    
    @IBOutlet var imageLabel: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        imageLabel.userInteractionEnabled = false
//        imageLabel.layer.cornerRadius = 26
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
