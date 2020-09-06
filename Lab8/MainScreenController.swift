//
//  MainScreenController.swift
//  Lab8
//
//  Created by Huynh, Thang N on 12/6/19.
//  Copyright © 2019 Huynh, Thang N. All rights reserved.
//
import UIKit
import SQLite3

class MainScreenController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    let ACTIVITYCELL: String = "ActivityCell"
    
    let dirPath: String = "\(NSHomeDirectory())/tmp"
    let filePath: String = "\(NSHomeDirectory())/tmp/activity.txt"
    
    let activityTableView: UITableView = UITableView()
    var activityList = [Activity]()
    
    public var bgcolor: UIColor = UIColor.gray
    public var buttoncolor: UIColor = UIColor.darkGray
    
    public var altbgcolor: UIColor = UIColor.gray
    public var altbuttoncolor: UIColor = UIColor.darkGray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgcolor
        
        // Label
        let label: UILabel = UILabel(frame: CGRect(x: view.center.x-100, y: 25, width: 200, height: 50))
        label.text = "Activities"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        
        // Activity Table
        activityTableView.frame = CGRect(x: view.center.x-175, y: 75, width: 350, height: 220)
        activityTableView.dataSource = self
        activityTableView.delegate = self
        activityTableView.backgroundColor = UIColor.white
        view.addSubview(activityTableView)
        
        // Buttons
        var button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 725, width: 200, height: 50)
        button.setTitle("NEW ACTIVITY", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(MainScreenController.addButtonPressed(sender:forEvent:)), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 800, width: 200, height: 50)
        button.setTitle("SETTINGS", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(MainScreenController.settingsButtonPressed(sender:forEvent:)), for: UIControl.Event.touchUpInside)
        view.addSubview(button)

        // File management
        createDirectory()
        restoreFromFile()
        print("File contents:")
        for activity in activityList {
            print("\(String(describing: activity.actDescription))")
        }
        
    }
    
    @objc func addButtonPressed(sender: UIButton, forEvent event: UIEvent) {
        let vc = NewActivityController()
        
        vc.bgcolor = altbgcolor
        vc.buttoncolor = altbuttoncolor
        
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(vc, animated: true, completion: {
            () -> Void in
            self.restoreFromFile()
        })
    }
    
    @objc func settingsButtonPressed(sender: UIButton, forEvent event: UIEvent) {
        let vc = SettingsController()
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(vc, animated: true, completion: {
            () -> Void in
            
        })
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ACTIVITYCELL) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: ACTIVITYCELL)
        let activity: Activity
        activity = activityList[indexPath.row]
        cell.textLabel?.text = activity.actDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // The following dynamically creates an object from a string
        tableView.deselectRow(at: indexPath, animated: false)
        
        let vc = NewActivityController()
        vc.bgcolor = altbgcolor
        vc.buttoncolor = altbuttoncolor
        vc.descriptionTextField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        for activity in activityList {
            if activity.actDescription == tableView.cellForRow(at: indexPath)?.textLabel?.text {
                vc.startDatePicker.date = activity.actStart! as Date
                vc.endDatePicker.date = activity.actEnd! as Date
            }
        }
        
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(vc, animated: true, completion: {
            () -> Void in
            self.restoreFromFile()
        })
        
    }
    
    // File
    private func displayDirectory() {
        print("Absolute path for Home Directory: \(NSHomeDirectory())")
        if let dirEnumerator = FileManager.default.enumerator(atPath: NSHomeDirectory()) {
            while let currentPath = dirEnumerator.nextObject() as? String {
                print(currentPath)
            }
        }
    }
    
    private func createDirectory() {
        print("Before directory is created...")
        displayDirectory()
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
            if isDir.boolValue {
                print("\(dirPath) exists and is a directory")
            }
            else {
                print("\(dirPath) exists and is not a directory")
            }
        }
        else {
            print("\(dirPath) does not exist")
            do {
                try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Error creating directory \(dirPath): \(error)")
            }
        }
        print("After directory is created...")
        displayDirectory()
    }
    
    private func saveToFile() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: activityList, requiringSecureCoding: false)
            if FileManager.default.createFile(atPath: filePath,
                                      contents: data,
                                      attributes: nil) {
                print("File \(filePath) successfully created")
            }
            else {
                print("File \(filePath) could not be created")
            }
        }
        catch {
            print("Error archiving data: \(error)")
        }
    }
    
    func restoreFromFile() {
        do {
            if let data = FileManager.default.contents(atPath: filePath) {
                print("Retrieving data from file \(filePath)")
                activityList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Activity] ?? [Activity]()
            }
            else {
                print("No data available in file \(filePath)")
                activityList = [Activity]()
            }
            activityTableView.reloadData()
        }
        catch {
            print("Error unarchiving data: \(error)")
        }
    }
    
    private func deleteFile() {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch {
            print("Error deleting file: \(error)")
        }
    }
    
}


class Activity: NSObject, NSCoding {
    let TNDES: String = "Activity Description"
    let TNSTART: String = "Start Time"
    let TNEND: String = "End Time"
    
    let actDescription: String?
    var actStart: Date?
    var actEnd: Date?
    
    init(actDescription: String?, actStart: Date?, actEnd: Date?){
        self.actDescription = actDescription
        self.actStart = actStart
        self.actEnd = actEnd
    }
    
    required init(coder aDecoder: NSCoder) {
        actDescription = aDecoder.decodeObject(forKey: TNDES) as? String
        actStart = aDecoder.decodeObject(forKey: TNSTART) as? Date
        actEnd = aDecoder.decodeObject(forKey: TNEND) as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(actDescription, forKey: TNDES)
        aCoder.encode(actStart, forKey: TNSTART)
        aCoder.encode(actEnd, forKey: TNEND)
    }
 
}
