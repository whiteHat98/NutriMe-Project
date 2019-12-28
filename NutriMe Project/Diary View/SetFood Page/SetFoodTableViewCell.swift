//
//  SetFoodTableViewCell.swift
//  NutriMe Project
//
//  Created by Randy Noel on 01/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

class SetFoodTableViewCell: UITableViewCell {

  @IBOutlet weak var imgIcon: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var lblDetail: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
