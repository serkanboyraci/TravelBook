//
//  ListViewController.swift
//  TravelBook2
//
//  Created by Ali serkan Boyracı  on 28.09.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID] ()
    var chosenTitle = ""
    var chosenTitleID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dont forget to add button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
                                                                                                                                                     

                                                                                          
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
    }
    
    //add button selector function
    @objc func addButtonClicked() {
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = titleArray[indexPath.row] // to show indexpath.row
        cell.contentConfiguration = content
        return cell
        
    }
    
    // to show selected data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenTitleID = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedID = chosenTitleID
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { // to use this, becase this called everytime in every opening.
        // this takes message(neplace) which in app.
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    
    @objc func getData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false // to do fast in big data
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                self.titleArray.removeAll(keepingCapacity: false) // not to take duplicate items
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    //all data in results(objectType), we want to take only name and id, we can easily take it if let structure and append it nameArray
                    
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                        
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    tableView.reloadData()
                }
            }
        } catch {
            print("ERROR")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // to take selected data to delete
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            // to delete only one item
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                break 
                            }
                        }
                    }
                }
            } catch {
                
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
