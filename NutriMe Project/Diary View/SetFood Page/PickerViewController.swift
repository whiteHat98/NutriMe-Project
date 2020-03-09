//
//  PickerViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 04/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

protocol DataTransfer{
    func getEatCategory(category: EatCategory)
    func getDate(toDate: Date)
    func getPortion(portion: Int)
}

class PickerViewController: UIViewController {
    
    var selectedCategory : EatCategory?
    var delegate: DataTransfer?
    var changedCategory : EatCategory?
    var choosenDate: Date?
    var portion: Int?
    
    @IBOutlet weak var picker: UIPickerView!
    
    let datePicker: UIDatePicker = UIDatePicker()
    @IBOutlet weak var pickerView: UIView!
    
    @IBAction func doneBtn(_ sender: Any) {
        if pickerCode == 1{
            delegate?.getPortion(portion: portion ?? 1)
        }else if pickerCode == 2{
            delegate?.getEatCategory(category: changedCategory ?? selectedCategory!)
        }else if pickerCode == 3{
            choosenDate = datePicker.date
            print(choosenDate)
            delegate?.getDate(toDate: choosenDate!)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var pickerCode: Int?
    
    let eatCategoryPicker : [EatCategory] = [.pagi, .siang, .malam]
    let portionPicker : [Int] = [1,2,3,4,5,6,7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    guard let selected = selectedCategory else { return }
        //    picker.selectedRow(inComponent: EatCategory.allValues.index(after: selected.ordinal()))
        
        picker.delegate = self
        picker.dataSource = self
        
        if pickerCode == 1{
            picker.isHidden = false
            
        }else if pickerCode == 2{
            picker.isHidden = false
            
            
            for (i, category) in eatCategoryPicker.enumerated(){
                if category == selectedCategory{
                    print("selectedCategory : \(selectedCategory)")
                    print("index: \(i)")
                    picker.selectRow(i, inComponent: 0, animated: true)
                    continue
                }
            }
        } else if pickerCode == 3{
            datePicker.setDate(Date(), animated: true)
            datePicker.datePickerMode = .date
            datePicker.frame = picker.frame
            picker.isHidden = true
            pickerView.addSubview(datePicker)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PickerViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerCode == 1{
            return 1
        }else if pickerCode == 2{
            return 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerCode == 1{
            self.portion = portionPicker[row]
        }else if pickerCode == 2{
            print(row)
            self.changedCategory = eatCategoryPicker[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerCode == 1{
            return portionPicker.count
        }else if pickerCode == 2{
            return eatCategoryPicker.count
        }
        return 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerCode == 1{
            return "\(portionPicker[row]) Portion(s)"
        }else if pickerCode == 2{
            return eatCategoryPicker[row].rawValue
        }
        return ""
    }
    
}

