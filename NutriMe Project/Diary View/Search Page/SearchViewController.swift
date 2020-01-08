//
//  SearchViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 30/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var foodTableView: UITableView!
    
    var foodList:[(food: String, calorie: Float)]=[("Nasi", 10),("Apple",12),("Nanas", 6),("Salmon",20)]
    var foodArr:[Hits]=[]
    var selectedSection: EatCategory?
    var selectedFood: Food?
    var delegate: SaveData?
    var newFoodInDiary : FoodInDiary?
    
    var searching = false
    var searchResult: [Hits] = []
    
    let requestAPI = RequestAPI()
    
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
                print(data)
                completionHandler(data, nil)
            }
        }
        )
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        foodTableView.reloadData()
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
                return searchResult.count + 1
            }
            return foodArr.count+1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == searchResult.count {
            
            let newFoodView : UINavigationController = UIStoryboard(name: "Diary", bundle: nil).instantiateViewController(identifier: "newFoodNavigationController") as! UINavigationController
            newFoodView.modalPresentationStyle = .fullScreen
            self.navigationController?.isNavigationBarHidden = true
            
            self.show(newFoodView, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchBar.selectedScopeButtonIndex == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFood") as! FoodTableViewCell
            //    print(foodArr.count)
            //    var food = foodArr[indexPath.row]
            
            var food = searchResult[indexPath.row]
            
            cell.lblFoodName.text = food.fields.item_name
            cell.lblCalories.text = "\(food.fields.nf_calories) Kkal"
            cell.lblNutrition.text = "Carb: \(food.fields.nf_total_carbohydrate), Pro: \(food.fields.nf_protein), Fat: \(food.fields.nf_total_fat)"
            cell.foodHits = food
            cell.delegate = self
            
            return cell
        }else if searchBar.selectedScopeButtonIndex == 1{
            if indexPath.row == searchResult.count{
                tableView.rowHeight = 44
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddNewFood", for: indexPath)
                
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension SearchViewController: ButtonAddFood{
    func buttonClicked(section: EatCategory) {
        
    }
    func sendFoodData(food: Food) {
        self.selectedFood = food
        performSegue(withIdentifier: "toEditDetail", sender: self)
    }
}

extension SearchViewController: SaveData{
    func dismissPage(dismiss: Bool) {
        if dismiss == true{
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            print("keluarrrrr")
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

