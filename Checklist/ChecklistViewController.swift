//
//  ViewController.swift
//  Checklist
//
//  Created by Paul Tader on 11/29/16.
//  Copyright © 2016 CircleTee. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
  
  var items: [ChecklistItem]
  
  required init?(coder aDecoder: NSCoder){
    items = [ChecklistItem]()
    super.init(coder: aDecoder)
    loadChecklistItems()

    print("The Documents folder is \(documentsDirectory())")
    print("Data file path is \(dataFilePath())")
  }
  
  func loadChecklistItems() {
    let path = dataFilePath()
    if let data = try? Data(contentsOf: path) {
      let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
      items = unarchiver.decodeObject(forKey: "ChecklistItems") as! [ChecklistItem]
      unarchiver.finishDecoding()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Checklist.plist")
  }
  
  func saveChecklistItem() {
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(items, forKey: "ChecklistItems")
    archiver.finishEncoding()
    data.write(to: dataFilePath(), atomically: true)
  }
  
  // The tableView object from the tableViewController (added to the storyboard) calls these functions.
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
    let item = items[indexPath.row]
    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)
  return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      let item = items[indexPath.row]
      item.toggleChecked()
      configureCheckmark(for: cell, with: item)
    }
    tableView.deselectRow(at: indexPath, animated: true)
    saveChecklistItem()
    
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath){
    items.remove(at: indexPath.row)
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
    saveChecklistItem()
  }
  
  func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
    let label = cell.viewWithTag(1001) as! UILabel
    
      if item.checked {
        label.text = "√"
      } else {
        label.text = ""
      }
    }
  
  func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
    let label = cell.viewWithTag(1000) as! UILabel
    label.text = item.text
  }
  
  // itemDetailViewControllerDidCancel protocol methods
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem){
    let newRowIndex = items.count
    items.append(item)
    
    //Tell the tableView we have a new row. It must be passed in as
    // an array. So, we make an array with one item.
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    let indexPaths = [indexPath]
    tableView.insertRows(at: indexPaths, with: .automatic)
    
    dismiss(animated: true, completion: nil)
    saveChecklistItem()
  }
  
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem){
    if let index = items.index(of: item) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
    dismiss(animated: true, completion: nil)
    saveChecklistItem()
  }
  
  // Gotta tell the View we are going to segue to who we are and that we're the delegate.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    if segue.identifier == "AddItem"{
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! ItemDetailViewController
      controller.delegate = self
    } else if segue.identifier == "EditItem" {
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! ItemDetailViewController
      controller.delegate = self
      
      // We need the row number in oder to send it to the editItem
      if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        controller.itemToEdit = items[indexPath.row]
      }
    }
  }

  
  
  
}
