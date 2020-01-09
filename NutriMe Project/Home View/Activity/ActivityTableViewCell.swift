//
//  ActivityTableViewCell.swift
//  NutriMe Project
//
//  Created by Randy Noel on 09/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

  @IBOutlet weak var activityTitle: UILabel!
  @IBOutlet weak var activityDesc: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
          self.accessoryType = .checkmark
        }else{
          self.accessoryType = .none
        }
        // Configure the view for the selected state
    }

}
