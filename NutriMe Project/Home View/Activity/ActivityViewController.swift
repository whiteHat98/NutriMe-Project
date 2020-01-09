//
//  ActivityViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 09/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

protocol UpdateData {
  func updateActivity(activity: Activity)
}

class ActivityViewController: UIViewController {

  var activities: [Activity] = []
  var activityLevel : Int?
  var selectedActivity : Activity?
  var delegate: UpdateData?
  
  
  @IBOutlet weak var activityTable: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      setActivityData()
      activityTable.delegate = self
      activityTable.dataSource = self
      activityTable.isScrollEnabled = false
      activityTable.tableFooterView = UIView()
      activityTable.selectRow(at: IndexPath(row: activityLevel ?? 0, section: 0), animated: false, scrollPosition: .none)
      selectedActivity = activities[activityLevel ?? 0]
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    if let activity = selectedActivity{
      delegate?.updateActivity(activity: activity)
    }
  }
  
  func setActivityData(){
    let lowActivity = Activity(id: 0, level: .low, desc: "driving, berjalan, office work, reading", caloriesMultiply: 1.2)
    let medActivity = Activity(id: 1, level: .medium, desc: "gardening, biking, fast walking", caloriesMultiply: 1.55)
    let highActivity = Activity(id: 2, level: .high, desc: "aerobics, badminton, jogging", caloriesMultiply: 1.725)
    activities.append(lowActivity)
    activities.append(medActivity)
    activities.append(highActivity)
  }
}

extension ActivityViewController: UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedActivity = activities[indexPath.row]
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    activities.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityTableViewCell
    
    cell.activityTitle.text = activities[indexPath.row].level.rawValue
    cell.activityDesc.text = activities[indexPath.row].desc
    
    return cell
  }
}
