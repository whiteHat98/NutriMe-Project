//
//  EditProfileTableViewCell.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 10/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var txtField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
