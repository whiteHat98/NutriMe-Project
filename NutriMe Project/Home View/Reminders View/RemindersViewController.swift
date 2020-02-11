//
//  RemindersViewController.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 11/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

class RemindersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var timePicker: UIDatePicker?
    var bfastTime = ""
    var lunchTime = ""
    var dinnerTime = ""
    var sarapanHour = 0
    var sarapanMin = 0
    var siangHour = 0
    var siangMin = 0
    var malamHour = 0
    var malamMin = 0
    var selectedIndex = 0
    var breakfastIsOn = false
    var lunchIsOn = false
    var dinnerIsOn = false
    
    var breakfastReminder: Reminder?
    var lunchReminder: Reminder?
    var dinnerReminder: Reminder?
    
    let database = CKContainer.default().publicCloudDatabase
    
    var userInfo : UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        hideKeyboardWhenTapped()
        
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        timePicker?.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
        
        initReminders()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if self.isMovingFromParent {
            UserDefaults.standard.set(sarapanHour, forKey: "sarapanHour")
            UserDefaults.standard.set(sarapanMin, forKey: "sarapanMinute")
            UserDefaults.standard.set(siangHour, forKey: "siangHour")
            UserDefaults.standard.set(siangMin, forKey: "siangMinute")
            UserDefaults.standard.set(malamHour, forKey: "malamHour")
            UserDefaults.standard.set(malamMin, forKey: "malamMinute")
            UserDefaults.standard.set(breakfastIsOn, forKey: "breakfastIsOn")
            UserDefaults.standard.set(lunchIsOn, forKey: "lunchIsOn")
            UserDefaults.standard.set(dinnerIsOn, forKey: "dinnerIsOn")
        }
    }
    
    func initReminders() {
        if let hour = UserDefaults.standard.value(forKey: "sarapanHour") as? Int {
            sarapanHour = hour
        }else{
            sarapanHour = 6
        }
        
        if let minute = UserDefaults.standard.value(forKey: "sarapanMinute") as? Int {
            sarapanMin = minute
        }
        else{
            sarapanMin = 0
        }
        
        if let hour = UserDefaults.standard.value(forKey: "siangHour") as? Int {
            siangHour = hour
        }
        else{
            siangHour = 12
        }
        
        if let minute = UserDefaults.standard.value(forKey: "siangMinute") as? Int {
            siangMin = minute
        }
        else{
            siangMin = 0
        }
        
        if let hour = UserDefaults.standard.value(forKey: "malamHour") as? Int {
            malamHour = hour
        }
        else{
            malamHour = 18
        }
        
        if let minute = UserDefaults.standard.value(forKey: "malamMinute") as? Int {
            malamMin = minute
        }
        else{
            malamMin = 0
        }
        
        if let breakfastReminderIsOn = UserDefaults.standard.value(forKey: "breakfastIsOn") as? Bool{
            if breakfastReminderIsOn == true {
                breakfastIsOn = true
            }
            else{
                breakfastIsOn = false
            }
        }
        else{
            breakfastIsOn = false
        }
        
        if let lunchReminderIsOn = UserDefaults.standard.value(forKey: "lunchIsOn") as? Bool{
            if lunchReminderIsOn == true {
                lunchIsOn = true
            }
            else{
                lunchIsOn = false
            }
        }
        else{
            lunchIsOn = false
        }
        
        if let dinnerReminderIsOn = UserDefaults.standard.value(forKey: "dinnerIsOn") as? Bool{
            if dinnerReminderIsOn == true {
                dinnerIsOn = true
            }
            else{
                dinnerIsOn = false
            }
        }
        else{
            dinnerIsOn = false
        }
        
        bfastTime = "\(setTimeString(time: sarapanHour)) : \(setTimeString(time: sarapanMin))"
        lunchTime = "\(setTimeString(time: siangHour)) : \(setTimeString(time: siangMin))"
        dinnerTime = "\(setTimeString(time: malamHour)) : \(setTimeString(time: malamMin))"
        
        tableView.reloadData()
    }
    
    func setTimeString(time: Int) -> String {
        var stringTime = ""
        if time < 10 {
            stringTime = "0\(time)"
        }
        else{
            stringTime = "\(time)"
        }
        return stringTime
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let date = timePicker!.date
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH : mm"
        
        let sarapanCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RemindersTableViewCell
        let siangCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! RemindersTableViewCell
        let malamCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! RemindersTableViewCell
        
        if selectedIndex == 0 {
            sarapanHour = components.hour!
            sarapanMin = components.minute!
            bfastTime = "\(setTimeString(time: sarapanHour)) : \(setTimeString(time: sarapanMin))"
            sarapanCell.timeText.text = bfastTime
            self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "breakfastReminder")
            self.appDelegate?.scheduleNotificationAtTime(notificationType: "Sarapan", body: "Ingat sarapan", hour: sarapanHour, minute: sarapanMin, identifier: "breakfastReminder")
        }
        else if selectedIndex == 1 {
            siangHour = components.hour!
            siangMin = components.minute!
            lunchTime = "\(setTimeString(time: siangHour)) : \(setTimeString(time: siangMin))"
            siangCell.timeText.text = lunchTime
            self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "lunchReminder")
            self.appDelegate?.scheduleNotificationAtTime(notificationType: "Makan Siang", body: "Ingat makan siang", hour: siangHour, minute: siangMin, identifier: "lunchReminder")
        }
        else if selectedIndex == 2 {
            malamHour = components.hour!
            malamMin = components.minute!
            dinnerTime = "\(setTimeString(time: malamHour)) : \(setTimeString(time: malamMin))"
            malamCell.timeText.text = dinnerTime
            self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "dinnerReminder")
            self.appDelegate?.scheduleNotificationAtTime(notificationType: "Makan Malam", body: "Ingat makan malam", hour: malamHour, minute: malamMin, identifier: "dinnerReminder")
        }
        
    }
    
    

}

extension RemindersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RemindersCell", for: indexPath) as! RemindersTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.titleText.text = "Breakfast"
            cell.timeText.text = bfastTime
            if !breakfastIsOn {
                cell.reminderSwitcher.isOn = false
                cell.titleText.isEnabled = false
                cell.timeText.isEnabled = false
                cell.timeText.textColor = UIColor.systemGray2
            }
            else{
                cell.reminderSwitcher.isOn = true
                cell.titleText.isEnabled = true
                cell.timeText.isEnabled = true
                cell.timeText.textColor = UIColor.label
                
            }
        case 1:
            cell.titleText.text = "Lunch"
            cell.timeText.text = lunchTime
            if !lunchIsOn {
                cell.reminderSwitcher.isOn = false
                cell.titleText.isEnabled = false
                cell.timeText.isEnabled = false
                cell.timeText.textColor = UIColor.systemGray2
            }
            else{
                cell.reminderSwitcher.isOn = true
                cell.titleText.isEnabled = true
                cell.timeText.isEnabled = true
                cell.timeText.textColor = UIColor.label
                
            }
        case 2:
            cell.titleText.text = "Dinner"
            cell.timeText.text = dinnerTime
            if !dinnerIsOn {
                cell.reminderSwitcher.isOn = false
                cell.titleText.isEnabled = false
                cell.timeText.isEnabled = false
                cell.timeText.textColor = UIColor.systemGray2
            }
            else{
                cell.reminderSwitcher.isOn = true
                cell.titleText.isEnabled = true
                cell.timeText.isEnabled = true
                cell.timeText.textColor = UIColor.label
            }
        default:
            return cell
        }
        cell.timeText.tag = indexPath.row
        cell.timeText.addTarget(self, action: #selector(textFieldTapped(textField:)), for: .touchDown)
        cell.reminderSwitcher.tag = indexPath.row
        cell.reminderSwitcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.timeText.inputView = timePicker
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        let switchRow = sender.tag
        
        if switchRow == 0 {
            if sender.isOn {
                self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "breakfastReminder")
                self.appDelegate?.scheduleNotificationAtTime(notificationType: "Sarapan", body: "Ingat sarapan", hour: sarapanHour, minute: sarapanMin, identifier: "breakfastReminder")
                breakfastIsOn = true
            }
            else{
                self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "breakfastReminder")
                breakfastIsOn = false
            }
        }
        else if switchRow == 1 {
            if sender.isOn {
                self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "lunchReminder")
                self.appDelegate?.scheduleNotificationAtTime(notificationType: "Makan Siang", body: "Ingat makan siang", hour: siangHour, minute: siangMin, identifier: "lunchReminder")
                lunchIsOn = true
            }
            else{
                self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "lunchReminder")
                lunchIsOn = false
            }
        }
        else if switchRow == 2 {
            if sender.isOn {
                self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "dinnerReminder")
                self.appDelegate?.scheduleNotificationAtTime(notificationType: "Makan Malam", body: "Ingat makan malam", hour: malamHour, minute: malamMin, identifier: "dinnerReminder")
                dinnerIsOn = true
            }
            else{
                self.appDelegate?.removePendingNotifivationWithIdentifier(identifier: "dinnerReminder")
                dinnerIsOn = false
            }
        }
        
        tableView.reloadData()
    }
    
    @objc func textFieldTapped(textField: UITextField) {
        let textFieldRow = textField.tag
        selectedIndex = textFieldRow
        print(selectedIndex)
    }
    
}
