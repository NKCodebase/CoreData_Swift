//
//  ViewController.swift
//  CoreData_Swift
//
//  Created by Krishna Nampally on 18/02/26.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var people: [CDPerson] = []
    
    // MARK: - Core Data Context
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
    }
    
    // MARK: - Save Data
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let ageText = ageTextField.text,
              let age = Int16(ageText) else { return }
        
        let newPerson = CDPerson(context: context)
        newPerson.name = name
        newPerson.age = age
        
        saveContext()
        fetchData()
        
        nameTextField.text = ""
        ageTextField.text = ""
    }
    
    // MARK: - Fetch Data
    /*func fetchData() {
        let request: NSFetchRequest<CDPerson> = CDPerson.fetchRequest()
        
        do {
            people = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Fetch error")
        }
    }*/
    
    func fetchData(searchText: String? = nil,
                   minAge: Int16? = nil,
                   sortAscending: Bool = true,
                   limit: Int? = nil,
                   offset: Int = 0) {
        
        let request: NSFetchRequest<CDPerson> = CDPerson.fetchRequest()
        
        // 🔹 1. Predicate Filtering
        var predicates: [NSPredicate] = []
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        if let minAge = minAge {
            predicates.append(NSPredicate(format: "age >= %d", minAge))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // 🔹 2. Sorting
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: sortAscending)
        ]
        
        // 🔹 3. Fetch Limit
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        // 🔹 4. Fetch Offset (Pagination)
        request.fetchOffset = offset
        
        do {
            people = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    /*
     
     1. Simple Fetch
     fetchData()
     
     2. Filter By Name
     fetchData(searchText: "krish")
     //Similar to
     WHERE name LIKE '%krish%'
     
     3. Filter By Age >= 25
     fetchData(minAge: 25)
     
     4. Sorting Descending
     fetchData(sortAscending: false)
     
     5. Pagination Example
        
        Add below
         var currentOffset = 0
         let pageSize = 5
     
        First Page
         currentOffset = 0
         fetchData(limit: pageSize, offset: currentOffset)
     
        Load Next Page:
         currentOffset += pageSize
         fetchData(limit: pageSize, offset: currentOffset)
     
     
     
     func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                    willDecelerate decelerate: Bool) {
         
         let position = scrollView.contentOffset.y
         let contentHeight = scrollView.contentSize.height
         
         if position > contentHeight - scrollView.frame.size.height {
             currentOffset += pageSize
             fetchData(limit: pageSize, offset: currentOffset)
         }
     }
     
     For true pagination in production:

     Instead of:
     people = try context.fetch(request)
     
     Use:
     people.append(contentsOf: try context.fetch(request))
     
     Otherwise it replaces old page.
     
     Better approach for fetch:
     
     let newResults = try context.fetch(request)

     if offset == 0 {
         people = newResults
     } else {
         people.append(contentsOf: newResults)
     }
     
     */
    
    // MARK: - Save Context
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Save error")
        }
    }
    
    // MARK: - Delete All data
    func deleteAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = CDPerson.fetchRequest()
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            people.removeAll()
            tableView.reloadData()
        } catch {
            print("Failed to delete all")
        }
    }
    
    // MARK: - Update Particular record
    func updatePerson(at index: Int, newName: String, newAge: Int16) {
        
        let person = people[index]
        
        // 🔹 Modify
        person.name = newName
        person.age = newAge
        
        // 🔹 Save
        do {
            try context.save()
            fetchData()
        } catch {
            print("Update failed")
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let person = people[indexPath.row]
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = "Age: \(person.age)"
        
        return cell
    }
    
    // MARK: - Delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            context.delete(people[indexPath.row])
            saveContext()
            fetchData()
        }
    }
    
    // MARK: - Update
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Update",
                                      message: "Modify Person",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = self.people[indexPath.row].name
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Age"
            textField.keyboardType = .numberPad
            textField.text = "\(self.people[indexPath.row].age)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            let newName = alert.textFields?[0].text ?? ""
            let newAge = Int16(alert.textFields?[1].text ?? "") ?? 0
            
            self.updatePerson(at: indexPath.row,
                              newName: newName,
                              newAge: newAge)
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}



/*
 
 If you use NSManagedObject Subclass....
 
 In your .xcdatamodeld file,

 Your Codegen setting is still set to “Class Definition”.
 
 Step 1:
  Open:
    CoreData_Swift.xcdatamodeld file
  Click On:
    CDPerson entity
 
 Step 2:
    On right side → Data Model Inspector
    
    Find Codegen

    Change it to:
        Manual/None  ✅
     
 
 Step 3: Clean Build and Build
 
 */
