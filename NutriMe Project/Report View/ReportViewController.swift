//
//  ReportViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 18/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import Charts
import CloudKit

struct Report{
    var recordName: String
    var caloriesGoal : Double
    var carbohydrateGoal : Double
    var proteinGoal: Double
    var fatGoal : Double
    var userCalories : Double?
    var userCarbohydrates : Double?
    var userFat : Double?
    var userProtein : Double?
    var date : Date
    var diaryID : [String]?
    var userID : String
//  var day: String
//  var carbo: Double
//  var fat: Double
//  var protein: Double
}

struct ChartValue{
    var userCarbohydrates : Double?
    var userFat : Double?
    var userProtein : Double?
}

class ReportViewController: UIViewController {

    let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var chartValues : [ChartValue] = []
    let database = CKContainer.default().publicCloudDatabase
  @IBOutlet weak var chartReportView: BarChartView!
    var thisWeekReports: [Report] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDataFromReportDB {
            self.setValues {
                DispatchQueue.main.async {
                    self.setChartValue()
                }
            }
            //print("Hello World")
        }
    }
  
    var randomV: Double{
      return Double(arc4random_uniform(UInt32(7) + 3))
    }
    
//    func generateData() -> [Report]{
//
//      var reports = [Report]()
//
//      for day in days{
//        let report = Report(day: day, carbo: randomV, fat: randomV, protein: randomV)
//        reports.append(report)
//      }
//      return reports
//    }
    func setValues(completion: @escaping() -> Void){
        chartValues.removeAll()
        var flag = true
        for i in 0..<7{
            flag = true
            if !thisWeekReports.isEmpty{
                for report in thisWeekReports{
                    if (checkDay(date: report.date)-1) == i {
                        let newChartValue = ChartValue(userCarbohydrates: report.userCarbohydrates, userFat: report.userFat, userProtein: report.userProtein)
                        chartValues.append(newChartValue)
                        //print(chartValues[i])
                        print(i+1)
                        flag = false
                    }
                }
                if flag{
                    let newChartValue = ChartValue(userCarbohydrates: 0, userFat: 0, userProtein: 0)
                    chartValues.append(newChartValue)
                    //print(chartValues[i])
                }
            }else{
                let newChartValue = ChartValue(userCarbohydrates: 0, userFat: 0, userProtein: 0)
                chartValues.append(newChartValue)
            }
        }
        print("ini chartValues \(chartValues.count)")
        completion()
    }
    
  func setChartValue(){
    
//    let reports = generateData()
//
//    var reportEntries = [BarChartDataEntry]()
//
//    var reportDays = [String]()
//
//    for (i,report) in reports.enumerated(){
//      let reportEntry = BarChartDataEntry(x: Double(i), yValues: [report.carbo, report.fat, report.protein])
//      reportEntries.append(reportEntry)
//      reportDays.append(report.day)
//    }
//
//
//    let chartDataSet = BarChartDataSet(entries: reportEntries, label: "Data")
//    let chartData = BarChartData(dataSets: [chartDataSet])
//
//    chartReportView.data = chartData
    
    
    let values = (0..<7).map { (i) -> BarChartDataEntry in
        var val: Double = chartValues[i].userCarbohydrates ?? 0
      return BarChartDataEntry(x: Double(i), y: val)
    }

    let values2 = (0..<7).map { (i) -> BarChartDataEntry in
        var val: Double = chartValues[i].userProtein ?? 0
      return BarChartDataEntry(x: Double(i), y: val)
    }

    let values3 = (0..<7).map { (i) -> BarChartDataEntry in
        var val: Double = chartValues[i].userFat ?? 0
      return BarChartDataEntry(x: Double(i), y: val)
    }

    let set1 = BarChartDataSet(entries: values, label: "test")
    set1.setColor(.red)
    let set2 = BarChartDataSet(entries: values2, label: "test2")
    set2.setColor(.yellow)
    let set3 = BarChartDataSet(entries: values3, label: "test3")
    set3.setColor(.blue)

    let data = BarChartData(dataSets: [set1, set2, set3])

    data.barWidth = 0.3
    data.groupBars(fromX: 0, groupSpace: 0.1, barSpace: 0)

    self.chartReportView.rightAxis.enabled = false

    self.chartReportView.highlighter = nil
    self.chartReportView.animate(yAxisDuration: 1.5, easing: .none)
    
    //legend -> Label
    let legend = chartReportView.legend
    legend.enabled = false
    legend.horizontalAlignment = .right
    legend.orientation = .vertical
    legend.xOffset = 10.0
    legend.yOffset = 10.0
    legend.yEntrySpace = 0
    
    
    //xAxis
    let xAxis = self.chartReportView.xAxis
    xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
    xAxis.labelPosition = .bottom
    xAxis.centerAxisLabelsEnabled = true
    xAxis.drawGridLinesEnabled = true
    xAxis.gridLineWidth = 2
    xAxis.spaceMax = 1
    xAxis.axisMinimum = 0
    xAxis.granularity = 1
    
    //yAxis
    let yAxis = self.chartReportView.leftAxis
    yAxis.spaceTop = 0.35
    yAxis.axisMinimum = 0
    yAxis.drawGridLinesEnabled = true
    yAxis.gridLineWidth = 0.1
    

    self.chartReportView.data = data
    self.chartReportView.drawBordersEnabled = false
    self.chartReportView.isUserInteractionEnabled = false
  }
    

  
    func getDataFromReportDB(_ completion: @escaping() -> Void){
    let predicate1 = NSPredicate(format: "userID == %@", UserDefaults.standard.string(forKey: "currentUserID")!)
    
    let query = CKQuery(recordType: "Report", predicate: predicate1)
    self.database.perform(query, inZoneWith: nil) { (records, err) in
        if err != nil{
            print("Fetch Report Error \(err)")
        }else{
            guard let recs = records else{return}
            self.thisWeekReports.removeAll()
            for rec in recs{
                if let rdate = rec.value(forKey: "date") as? Date{
                    if self.isDayInThisWeek(date: rdate){
                        let newRecord = Report(recordName: rec.recordID.recordName, caloriesGoal: rec.value(forKey: "caloriesGoal") as! Double, carbohydrateGoal: rec.value(forKey: "carbohydrateGoal") as! Double, proteinGoal: rec.value(forKey: "proteinGoal") as! Double, fatGoal: rec.value(forKey: "fatGoal") as! Double, userCalories: rec.value(forKey: "userCalories") as? Double, userCarbohydrates: rec.value(forKey: "userCarbohydrates") as? Double, userFat: rec.value(forKey: "userFat") as? Double, userProtein: rec.value(forKey: "userProtein") as? Double, date: (rec.value(forKey: "date") as? Date)!, diaryID: rec.value(forKey: "diaryID") as? [String], userID: rec.value(forKey: "userID") as! String)
                        self.thisWeekReports.append(newRecord)
                        //print(self.checkDay(date: newRecord.date))
                        print("enter a new world \(self.thisWeekReports)")
                    }
                }
            }
            completion()
        }
    }
  }
    
    func checkDay(date: Date)->Int{
        let component = Calendar.current.dateComponents([.weekday], from: date)
        print(component.weekday)
        return component.weekday!
    }
}

extension UIViewController{
    func isDayInThisWeek(date: Date) -> Bool{
        let currentWeek = Calendar.current.component(.weekOfMonth, from: Date())
        let dateWeek = Calendar.current.component(.weekOfMonth, from: date)
        return currentWeek == dateWeek
    }
    
}
