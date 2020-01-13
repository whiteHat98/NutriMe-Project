//
//  RemindersTableViewCell.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 11/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var reminderSwitcher: UISwitch!
    @IBOutlet weak var timeText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
