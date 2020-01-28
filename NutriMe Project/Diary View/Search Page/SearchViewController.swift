//
//  SearchViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 30/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var foodTableView: UITableView!
    
    var foodList:[(food: String, calorie: Float)]=[("Nasi", 10),("Apple",12),("Nanas", 6),("Salmon",20)]
    var foodArr:[Hits]=[]
    var selectedSection: EatCategory?
    var selectedFood: UserFood?
    var delegate: SaveData?
    var newFoodInDiary : FoodInDiary?
    
//    var userFood: Food?
    var user: UserInfo?
    var userFood: UserFood?
    var foodMakro: FoodMakro?
    var arrayUserFood: [UserFood] = []
    var arrayFoodMakro: [FoodMakro] = []
    
    var searching = false
    var searchResult: [Hits] = []
    
    let requestAPI = RequestAPI()
    
    let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodTableView.delegate = self
        foodTableView.dataSource = self
        searchBar.delegate = self
        hideKeyboardWhenTappedAround()
        
        //      for food in foodList{
        //        let foodi = Food(name: food.food, calorie: food.calorie, perEach: 10)
        //        foodArr.append(foodi)
        //      }
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.dismissPage(dismiss: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        if !CheckInternet.Connection(){
//            let alert = UIAlertController(title: "Internet Connection", message: "Internet connection required please check your internet connection!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            
//            self.present(alert, animated: true, completion: nil)
//        }
//        
        let userID:String = UserDefaults.standard.value(forKey: "currentUserID") as! String
        
        let userFoodQuery = CKQuery(recordType: "Food", predicate: NSPredicate(format: "userID == %@", userID))
        
        database.perform(userFoodQuery, inZoneWith: nil) { (record, error) in
            if error == nil {
                self.arrayUserFood.removeAll()
                for data in record! {
                    
                    self.userFood = UserFood(ID: data.recordID.recordName, name: data.value(forKey: "name") as! String, calories: data.value(forKey: "calories") as! Float, restrictions: nil)
                    
//                    print(newFood)
                    
//                    foodRestrictions.append(data.value(forKey: "restrictions") as! [String])
                    if let food = self.userFood{
                        self.arrayUserFood.append(food)
                    }
                    
                }
                
                
                self.queryMakros()
                
            }
        }
        
    }
    
    func queryMakros() {
        let foodMakros = CKQuery(recordType: "Makros", predicate: NSPredicate(value: true))
        
        database.perform(foodMakros, inZoneWith: nil) { (record, error) in
            if error == nil {
                self.arrayFoodMakro.removeAll()
                
                for data in record! {
                    
                    self.foodMakro = FoodMakro(FoodID: data.value(forKey: "foodID") as! String, protein: data.value(forKey: "protein") as! Float, fat: data.value(forKey: "fat") as! Float, carbohydrate: data.value(forKey: "carbohydrate") as! Float)

                    for (i,food) in self.arrayUserFood.enumerated(){
                        if food.ID == self.foodMakro?.FoodID{
                            self.arrayUserFood[i].makros = self.foodMakro
                        }
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.foodTableView.reloadData()
                }
                
                //print(self.arrayUserFood)
               // print(self.arrayFoodMakro)
               
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let food = newFoodInDiary else{return}
        delegate?.saveData(food: food.food, eatCategory: food.category, portion: food.portion!, date: food.date!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditDetail"{
            let navBar = segue.destination as! UINavigationController
            let vc = navBar.topViewController as! SetFoodViewController
            vc.selectedFood = self.selectedFood
            vc.selectedSection = self.selectedSection
            vc.delegate = self
        }
    }
}

extension SearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("didchangeeee...")
        self.searchResult.removeAll()
        self.foodTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        
        //            searchResult = foodArr.filter({ (food: Food) -> Bool in
        //              return food.name.lowercased().contains(searchText.lowercased())
        //            })
        if searchBar.selectedScopeButtonIndex == 0{
            searchInTheAPI(searchText) { (data, err) in
                if err == nil{
                    DispatchQueue.main.async {
                        self.searchResult = data!
                        self.foodTableView.reloadData()
                        print("JUMLAH: \(self.searchResult.count)")
                    }
                }else{
                    DispatchQueue.main.async {
                        self.searchResult.removeAll()
                        self.foodTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func searchInTheAPI(_ searchText : String, completionHandler: @escaping([Hits]?, Error?) -> Void){
        self.requestAPI.requestAPI(food: searchText.lowercased(), completion: { result in
            switch result{
            case .failure(let error):
                print(error)
                completionHandler(nil,error)
            case .success(let data):
                //print(data)
                completionHandler(data, nil)
            }
        }
        )
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//         searching = false
//        searchBar.text = ""
//        foodTableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.selectedScopeButtonIndex == 0{
            if searching{
                return searchResult.count
            }
            return foodArr.count
        }else{
            if searching{
                return arrayUserFood.count + 1
            }
            return arrayUserFood.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchBar.selectedScopeButtonIndex == 1{
          if indexPath.row == 0 {
            return 45
          }
        }
        return 92
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if searchBar.selectedScopeButtonIndex == 1{
        if indexPath.row == 0 {
            
            let newFoodView : UINavigationController = UIStoryboard(name: "Diary", bundle: nil).instantiateViewController(identifier: "newFoodNavigationController") as! UINavigationController
            newFoodView.modalPresentationStyle = .fullScreen
            self.navigationController?.isNavigationBarHidden = true
            
            self.show(newFoodView, sender: self)
        }
      }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchBar.selectedScopeButtonIndex == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFood") as! FoodTableViewCell
            //    print(foodArr.count)
            //    var food = foodArr[indexPath.row]
            
            let food = searchResult[indexPath.row]
            
            cell.lblFoodName.text = food.fields.item_name
            cell.lblCalories.text = "\(food.fields.nf_calories) Kkal"
            cell.lblNutrition.text = "Carb: \(food.fields.nf_total_carbohydrate), Pro: \(food.fields.nf_protein), Fat: \(food.fields.nf_total_fat)"
            cell.foodHits = food
            cell.isUserFood = false
            cell.delegate = self
            
            return cell
        }else if searchBar.selectedScopeButtonIndex == 1{
            if indexPath.row == 0{
                tableView.rowHeight = 44
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddNewFood", for: indexPath)
                
                
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFood") as! FoodTableViewCell
            //    print(foodArr.count)
            //    var food = foodArr[indexPath.row]
            
            if arrayUserFood[indexPath.row - 1].makros != nil {
                //    print(foodArr.count)
                //    var food = foodArr[indexPath.row]
                
                let food = arrayUserFood[indexPath.row - 1]
                cell.lblFoodName.text = food.name
                cell.lblCalories.text = "\(food.calories) Kkal"
                cell.lblNutrition.text = "Carb: \(food.makros!.carbohydrate), Pro: \(food.makros!.protein), Fat: \(food.makros!.fat)"
                cell.userFood = food
                cell.isUserFood = true
                cell.delegate = self
            }
            
            
            return cell
        }
        return UITableViewCell()
    }
}

extension SearchViewController: ButtonAddFood{
    func buttonClicked(section: EatCategory) {
        
    }
    
    func sendFoodData(food: UserFood) {
        self.selectedFood = food
        performSegue(withIdentifier: "toEditDetail", sender: self)
    }
}

extension SearchViewController: SaveData{
    func dismissPage(dismiss: Bool) {
        if dismiss{
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveData(food: Food, eatCategory: EatCategory, portion: Float, date: Date) {
        newFoodInDiary = FoodInDiary(category: eatCategory, food: food, date: date, portion: portion)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

