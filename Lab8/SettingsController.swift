//
//  SettingsController.swift
//  Lab8
//
//  Created by Huynh, Thang N on 12/6/19.
//  Copyright © 2019 Huynh, Thang N. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    let ACTIVITYCELL: String = "ActivityCell"
    
    let dirPath: String = "\(NSHomeDirectory())/tmp"
    let filePath: String = "\(NSHomeDirectory())/tmp/activity.txt"
    
    let activityTableView: UITableView = UITableView()
    var activityList = [Activity]()
    
    public var bgcolor: UIColor = UIColor.gray
    public var buttoncolor: UIColor = UIColor.darkGray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgcolor
        
        // Buttons
        var button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 650, width: 200, height: 50)
        button.setTitle("MAIN COLOR", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(SettingsController.changeMainScreenColor), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 575, width: 200, height: 50)
        button.setTitle("NEW ACTIVITY COLOR", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(SettingsController.changeNewActivityColor), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 725, width: 200, height: 50)
        button.setTitle("DELETE SAVES", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(SettingsController.clearActivities), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(SettingsController.dismissViewController)))
        
        // File management
        createDirectory()
        restoreFromFile()
        print("File contents:")
        for activity in activityList {
            print("\(String(describing: activity.actDescription))")
        }
    }

    @objc private func dismissViewController() {
        if let pvc = self.presentingViewController as? MainScreenController {
            pvc.restoreFromFile()
            pvc.viewDidLoad()
        }
        presentingViewController?.dismiss(animated: true, completion: {()
            -> Void in
            
        })
    }
    
    @objc private func changeMainScreenColor() {
        if let pvc = self.presentingViewController as? MainScreenController {
            if (pvc.bgcolor == UIColor.gray) {
                pvc.bgcolor = UIColor.white
            }
            else {
                pvc.bgcolor = UIColor.gray
            }
            
            if (pvc.buttoncolor == UIColor.darkGray) {
                pvc.buttoncolor = UIColor.lightGray
            }
            else {
                pvc.buttoncolor = UIColor.darkGray
            }
            pvc.viewDidLoad()
            //dismissViewController()
        }
    }
    
    @objc private func changeNewActivityColor() {
        if let pvc = self.presentingViewController as? MainScreenController {
            if (pvc.altbgcolor == UIColor.gray) {
                pvc.altbgcolor = UIColor.white
            }
            else {
                pvc.altbgcolor = UIColor.gray
            }
            
            if (pvc.altbuttoncolor == UIColor.darkGray) {
                pvc.altbuttoncolor = UIColor.lightGray
            }
            else {
                pvc.altbuttoncolor = UIColor.darkGray
            }
            pvc.viewDidLoad()
            //dismissViewController()
        }
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
    
    private func restoreFromFile() {
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
    
    // Clear and add new activities
    @objc func clearActivities() {
        activityList.removeAll()
        deleteFile()
        
        activityTableView.reloadData()
        dismissViewController()
    }
    
}
