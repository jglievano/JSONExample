//
//  ViewController.swift
//  JSONExample
//
//  Created by Gabriel Lievano on 11/9/16.
//  Copyright © 2016 Juan Gabriel Lievano. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var output: UITextView!
  @IBOutlet weak var tableView: UITableView!
  
  // Helper structure with the name of keys. Is better this way to avoid typos.
  struct dataKeys {
    static let name = "name"
    static let lastname = "lastname"
    static let friends = "friends"
  }
  
  // This is the key used to stored modified data. Unlike Json, this uses serializable Swift
  // objects.
  // Make sure the key name is unique to your app, that's why I prefix with the domain.
  static let userDefaultsKey = "me.jglievano.data"
  
  // data holds the structure to all data managed by this example. It is originally loaded from
  // example.json but is after modified with a list of friends obtained from either a locally stored
  // json file, an object stored in user defaults, or an object stored using NSKeyedArchiver.
  var data: [String : Any] = [String : Any]()
  
  // Save the list of friends.
  func saveData(_ store: [String]) {
    let dir = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    let url = dir.appendingPathComponent("keyed")
    NSKeyedArchiver.archiveRootObject(store, toFile: url.path)
    do {
      let json = try JSONSerialization.data(withJSONObject: store, options: [])
      try json.write(to: dir.appendingPathComponent("example.json"))
    } catch {}
  }
  
  // Returns the list of friends stored.
  func loadData() -> [String] {
    let dir = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    
    // ATTENTION!
    // Comment the next 4 lines if you want to load local json.
    let url = dir.appendingPathComponent("keyed")
    if let store = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? [String] {
      return store
    }
    
    // Uncomment to see UserDefaults loading. UserDefaults should not be used to store big amounts
    // of data. Is more a way to store user preferences.
    /*
    return
        UserDefaults.standard.value(forKey: ViewController.userDefaultsKey) as! [String]
    */
    
    do {
      let raw = try Data(contentsOf: dir.appendingPathComponent("example.json"))
      let json = try JSONSerialization.jsonObject(with: raw, options: .allowFragments)
      return json as! [String]
    } catch {}
    
    return data[dataKeys.friends] as! [String]
  }
  
  // This method is linked to the 'add' button in the toolbar.
  @IBAction func addFriend(_ sender: UIBarButtonItem) {
    // We create an alert and ask the user to type in a name. That name is the name of the friend.
    let alert = UIAlertController(title: "New friend",
                                  message: "Add a new friend",
                                  preferredStyle: .alert)
    let saveAction = UIAlertAction(title: "Save", style: .default) {
      [unowned self] action in
      
      // We store the name in the textfield on a variable called 'nameToSave'.
      guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
        return
      }
      
      // += on arrays work just like append().
      // In this part we modify the list, so we store that in the user defaults.
      if var friends = self.data[dataKeys.friends] as? [String] {
        friends += [nameToSave]
        // This just updates the current data, for display purposes.
        self.data[dataKeys.friends] = friends
        // Updates or Adds friends array with the specified key.
        UserDefaults.standard.set(friends, forKey: ViewController.userDefaultsKey)
        self.saveData(friends)
      }
      self.tableView.reloadData()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    present(alert, animated: true)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Makes sure there's such thing as a friends field. If not then returns 0.
    // If the tables doesn't display anything, the reason is most probably that the friends field
    // on the json file is not set properly.
    if let friends = data[dataKeys.friends] as? [String] {
      return friends.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell")!
    guard let friends = data[dataKeys.friends] as? [String] else {
      return cell
    }
    cell.textLabel?.text = friends[indexPath.row]
    return cell
  }
  
  // Helper function that returns the data from example.json in the main bundle.
  func loadDataFromBundle() -> [String : Any]? {
    let path = Bundle.main.url(forResource: "example", withExtension: "json")!
    let json: Any!
    do {
      let data = try Data(contentsOf: path)
      json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    } catch {
      print("Error loading data")
      return nil
    }
    
    return json as? [String : Any]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // We always get the general information from the example.json file.
    data = loadDataFromBundle()!
    data[dataKeys.friends] = loadData()
    
    // Display data in view.
    guard let name = data[dataKeys.name] as? String,
      let lastname = data[dataKeys.lastname] as? String else {
        print("json has missing fields")
        return
    }
    var out = "name: " + name
    out = out + "\nlast name: " + lastname
    self.output.text = out
    
    tableView.reloadData()
  }

}

