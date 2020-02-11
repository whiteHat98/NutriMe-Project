//
//  mineralTableViewCell.swift
//  NutriMe Project
//
//  Created by Randy Noel on 15/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

class mineralTableViewCell: UITableViewCell {

    @IBOutlet weak var waterProgressBar: UIProgressView!
    @IBOutlet weak var waterLbl: UILabel!
    @IBOutlet weak var waterAddBtn: UIButton!
    var numOfGlass: Float = 0.0
    var numOfMinGlass: Float = 8.0
    @IBAction func addWater(_ sender: Any) {
        showAlert(title: "Add Mineral", adding: true)

    }
    
    @IBAction func minWater(_ sender: Any) {
        showAlert(title: "Remove Mineral", adding: false)
 
    }
    
    func showAlert(title: String, adding: Bool){
        let alert = UIAlertController(title: title, message: "You will \(title) to your data!", preferredStyle: .alert)
        
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: .some({ (_) in
            if adding{
                self.numOfGlass += 1
                UserDefaults.standard.set(self.numOfGlass, forKey: "numOfGlass")
                self.waterProgressBar.setProgress(Float(self.numOfGlass/self.numOfMinGlass), animated: true)
                self.waterLbl.text = "\(Int(self.numOfGlass))/\(Int(self.numOfMinGlass))"
            }else{
                self.numOfGlass -= 1
                UserDefaults.standard.set(self.numOfGlass, forKey: "numOfGlass")
                self.waterProgressBar.setProgress(Float(self.numOfGlass/self.numOfMinGlass), animated: true)
                self.waterLbl.text = "\(Int(self.numOfGlass))/\(Int(self.numOfMinGlass))"
            }
        }))
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        guard let number = UserDefaults.standard.value(forKey: "numOfGlass") as? Float else {
            waterLbl.text = "\(Int(numOfGlass))/\(Int(numOfMinGlass))"
            waterProgressBar.progress = 0
            return
        }
        numOfGlass = number

        waterLbl.text = "\(Int(number))/\(Int(numOfMinGlass))"
        waterProgressBar.setProgress(Float(numOfGlass/numOfMinGlass), animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
