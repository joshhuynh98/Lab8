//
//  NewActivityController.swift
//  Lab8
//
//  Created by Huynh, Thang N on 12/6/19.
//  Copyright © 2019 Huynh, Thang N. All rights reserved.
//

import SwiftUI
import SQLite3

class NewActivityController: UIViewController, UITextFieldDelegate {
 
    let ACTIVITYCELL: String = "ActivityCell"
    
    let dirPath: String = "\(NSHomeDirectory())/tmp"
    let filePath: String = "\(NSHomeDirectory())/tmp/activity.txt"
    
    let descriptionTextField: UITextField = UITextField()
    
    let startDatePicker: UIDatePicker = UIDatePicker()
    let endDatePicker: UIDatePicker = UIDatePicker()
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    let activityTableView: UITableView = UITableView()
    var activityList = [Activity]()
    
    public var bgcolor: UIColor = UIColor.gray
    public var buttoncolor: UIColor = UIColor.darkGray
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgcolor
        
        // Label
        var label: UILabel = UILabel(frame: CGRect(x: view.center.x-100, y: 25, width: 200, height: 50))
        label.text = "New Activity"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 24.0)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        
        label = UILabel(frame: CGRect(x: view.center.x-100, y: 200, width: 200, height: 50))
        label.text = "Start Time"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20.00)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        
        label = UILabel(frame: CGRect(x: view.center.x-100, y: 425, width: 200, height: 50))
        label.text = "End Time"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20.00)
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        
        // Description input
        descriptionTextField.frame = CGRect(x: view.center.x-135, y: 100, width: 270, height: 50)
        descriptionTextField.textColor = UIColor.black
        descriptionTextField.font = UIFont.systemFont(ofSize: 24.0)
        descriptionTextField.placeholder = "<enter description>"
        descriptionTextField.backgroundColor = UIColor.white
        descriptionTextField.keyboardType = UIKeyboardType.default
        descriptionTextField.returnKeyType = UIReturnKeyType.done
        descriptionTextField.clearButtonMode = UITextField.ViewMode.always
        descriptionTextField.layer.borderColor = UIColor.black.cgColor
        descriptionTextField.borderStyle = UITextField.BorderStyle.line
        descriptionTextField.layer.borderWidth = 1
        descriptionTextField.delegate = self
        view.addSubview(descriptionTextField)
        
        // Date input
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        startDatePicker.frame = CGRect(x: 30, y: 250, width: self.view.frame.width-60, height: 150)
        startDatePicker.timeZone = NSTimeZone.local
        startDatePicker.backgroundColor = UIColor.white
        startDatePicker.addTarget(self, action: #selector(NewActivityController.datePickerValueChanged(_:)), for: .valueChanged)
        view.addSubview(startDatePicker)
        
        endDatePicker.frame = CGRect(x: 30, y: 475, width: self.view.frame.width-60, height: 150)
        endDatePicker.timeZone = NSTimeZone.local
        endDatePicker.backgroundColor = UIColor.white
        endDatePicker.addTarget(self, action: #selector(NewActivityController.datePickerValueChanged(_:)), for: .valueChanged)
        view.addSubview(endDatePicker)
        
        // Buttons
        var button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 650, width: 200, height: 50)
        button.setTitle("ADD/UPDATE", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(NewActivityController.addActivity), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: view.center.x-100, y: 725, width: 200, height: 50)
        button.setTitle("DELETE", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = buttoncolor
        button.addTarget(self, action: #selector(NewActivityController.clearActivity), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        
        // File management
        createDirectory()
        restoreFromFile()
        print("File contents:")
        for activity in activityList {
            print("\(String(describing: activity.actDescription))")
        }
        
        view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(NewActivityController.dismissViewController)))
    }

    @objc private func dismissViewController() {
        if let pvc = self.presentingViewController as? MainScreenController {
            pvc.restoreFromFile()
        }
        presentingViewController?.dismiss(animated: true, completion: {()
            -> Void in
            
        })
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let selectedDate: String = dateFormatter.string(from: sender.date)
        print("Selected value \(selectedDate)")
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
    
    // Clear and add new activities
    @objc func clearActivity() {
        var index = 0
        
        for activity in activityList {
            if activity.actDescription == descriptionTextField.text {
                break
            } else {
                index += 1
            }
        }
        activityList.remove(at: index)
        
        saveToFile()
        
        activityTableView.reloadData()
        dismissViewController()
    }

    @objc func addActivity() {
        let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !description!.isEmpty {
            descriptionTextField.layer.borderWidth = 1
            descriptionTextField.layer.borderColor = UIColor.black.cgColor
            
            var notExist = true
            
            for activity in activityList {
                if activity.actDescription == description {
                    notExist = false
                    activity.actStart = startDatePicker.date
                    activity.actEnd = endDatePicker.date
                }
            }
            
            if notExist {
                activityList.append(Activity(actDescription: description, actStart: startDatePicker.date, actEnd: endDatePicker.date))
            }
            
            descriptionTextField.text = ""
            saveToFile()
            activityTableView.reloadData()
            
            dismissViewController()
        }
        else {
            descriptionTextField.layer.borderWidth = 3
            descriptionTextField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
}
