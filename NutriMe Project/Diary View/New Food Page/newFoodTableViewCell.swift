//
//  newFoodTableViewCell.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 07/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

class newFoodTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var textField: UITextField!

}
