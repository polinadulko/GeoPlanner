//
//  AddTaskViewController.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/25/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var saveBarButtonItem = UIBarButtonItem()
    var cancelBarButtonItem = UIBarButtonItem()
    var managedObjectContext: NSManagedObjectContext?
    let scrollView = UIScrollView()
    let contentView = UIView()
    let nameTextView = UITextView()
    let nameTextViewPlaceholder = "Task"
    var datePicker = UIDatePicker()
    let moveTaskLabel = UILabel()
    let moveTaskSwitch = UISwitch()
    let connectToPlaceLabel = UILabel()
    let connectToPlaceSwitch = UISwitch()
    let typeOfPlaceLabel = UILabel()
    let typeOfPlacePickerView = UIPickerView()
    var selectedTypeOfPlace = "-"
    let typesOfPlaces = ["-", "Airport", "Amusement park", "Aquarium", "Art gallery", "ATM", "Bakery", "Bank", "Bar", "Beauty salon", "Bicycle store", "Book store", "Bus station", "Cafe", "Car dealer", "Car rental", "Car repair", "Car wash", "Casino", "City hall", "Clothing store", "Convenience store", "Dentist", "Department store", "Doctor", "Electronics store", "Embassy", "Florist", "Furniture store", "Gas station", "Gym", "Hair care", "Hardware store", "Home goods store", "Hospital", "Insurance agency", "Jewelry store", "Library", "Liquor store", "Locksmith", "Lodging", "Meal delivery", "Meal takeaway", "Movie theater", "Moving company", "Museum", "Park", "Parking", "Pet store", "Pharmacy", "Police", "Post office", "Real estate agency", "Restaurant", "School", "Shoe store", "Shopping mall", "Spa", "Stadium", "Store", "Subway station", "Supermarket", "Taxi stand", "Train station", "Travel agency", "Veterinary care", "Zoo"]
    let keywordForPlaceTextField = UITextField()
    var keyboardHeight:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stopEditing)))
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        nameTextView.delegate = self
        nameTextView.text = nameTextViewPlaceholder
        nameTextView.textColor = UIColor.lightGray
        nameTextView.layer.borderColor = UIColor.lightGray.cgColor
        nameTextView.layer.borderWidth = 1
        nameTextView.layer.cornerRadius = 5
        nameTextView.font = UIFont.systemFont(ofSize: 14.0)
        nameTextView.isScrollEnabled = false
        nameTextView.setContentOffset(.zero, animated: false)
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameTextView)
        nameTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
        nameTextView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        nameTextView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85).isActive = true
        
        datePicker = UIDatePicker(frame: UIScreen.main.bounds)
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.layer.borderWidth = 0.1
        datePicker.layer.borderColor = UIColor.lightGray.cgColor
        datePicker.layer.cornerRadius = 5
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: nameTextView.bottomAnchor, constant: 20).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        moveTaskSwitch.isOn = false
        moveTaskSwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(moveTaskSwitch)
        moveTaskSwitch.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 30).isActive = true
        moveTaskSwitch.leftAnchor.constraint(equalTo: nameTextView.leftAnchor).isActive = true
        
        moveTaskLabel.text = "Move task to the next day until it's checked as done"
        moveTaskLabel.numberOfLines = 0
        moveTaskLabel.lineBreakMode = .byWordWrapping
        moveTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(moveTaskLabel)
        moveTaskLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20).isActive = true
        moveTaskLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        moveTaskLabel.leftAnchor.constraint(equalTo: moveTaskSwitch.rightAnchor, constant: 15).isActive = true
        moveTaskLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7).isActive = true

        connectToPlaceSwitch.isOn = false
        connectToPlaceSwitch.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(connectToPlaceSwitch)
        connectToPlaceSwitch.topAnchor.constraint(equalTo: moveTaskSwitch.bottomAnchor, constant: 22).isActive = true
        connectToPlaceSwitch.leftAnchor.constraint(equalTo: moveTaskSwitch.leftAnchor).isActive = true

        connectToPlaceLabel.text = "Connect task to place"
        connectToPlaceLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(connectToPlaceLabel)
        connectToPlaceLabel.topAnchor.constraint(equalTo: moveTaskLabel.bottomAnchor, constant: 18).isActive = true
        connectToPlaceLabel.leftAnchor.constraint(equalTo: connectToPlaceSwitch.rightAnchor, constant: 15).isActive = true

        typeOfPlaceLabel.text = "Type of place:"
        typeOfPlaceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeOfPlaceLabel)
        typeOfPlaceLabel.topAnchor.constraint(equalTo: connectToPlaceLabel.bottomAnchor, constant: 30).isActive = true
        typeOfPlaceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30).isActive = true
        
        typeOfPlacePickerView.delegate = self
        typeOfPlacePickerView.dataSource = self
        typeOfPlacePickerView.layer.borderColor = UIColor.lightGray.cgColor
        typeOfPlacePickerView.layer.borderWidth = 0.1
        typeOfPlacePickerView.layer.cornerRadius = 5
        typeOfPlacePickerView.translatesAutoresizingMaskIntoConstraints = false
        typeOfPlacePickerView.selectRow(0, inComponent: 0, animated: true)
        contentView.addSubview(typeOfPlacePickerView)
        typeOfPlacePickerView.topAnchor.constraint(equalTo: typeOfPlaceLabel.bottomAnchor, constant: 15).isActive = true
        typeOfPlacePickerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        keywordForPlaceTextField.placeholder = "Keyword for place"
        keywordForPlaceTextField.borderStyle = .roundedRect
        keywordForPlaceTextField.font = UIFont.systemFont(ofSize: 14)
        keywordForPlaceTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(keywordForPlaceTextField)
        keywordForPlaceTextField.topAnchor.constraint(equalTo: typeOfPlacePickerView.bottomAnchor, constant: 15).isActive = true
        keywordForPlaceTextField.leftAnchor.constraint(equalTo: nameTextView.leftAnchor).isActive = true
        keywordForPlaceTextField.widthAnchor.constraint(equalTo: nameTextView.widthAnchor).isActive = true
        keywordForPlaceTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentView.bottomAnchor.constraint(equalTo: keywordForPlaceTextField.bottomAnchor, constant: 30).isActive = true
        
        connectToPlaceSwitch.addTarget(self, action: #selector(isTaskConnectedToPlace(sender:)), for: .valueChanged)
        dontConnectTaskToPlace()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func isTaskConnectedToPlace(sender: UISwitch) {
        if sender.isOn {
            connectTaskToPlace()
        } else {
            dontConnectTaskToPlace()
        }
    }
    
    func connectTaskToPlace() {
        typeOfPlaceLabel.isHidden = false
        typeOfPlacePickerView.isHidden = false
        keywordForPlaceTextField.isHidden = false
    }
    
    func dontConnectTaskToPlace() {
        typeOfPlaceLabel.isHidden = true
        typeOfPlacePickerView.isHidden = true
        keywordForPlaceTextField.isHidden = true
    }
    
    @objc func stopEditing() {
        contentView.endEditing(true)
    }
    
    //MARK:- Bar buttons actions
    @objc func saveTask() {
        if connectToPlaceSwitch.isOn && selectedTypeOfPlace == "-" && (keywordForPlaceTextField.text?.isEmpty)! {
            showAlert(info: "Add type of place or keyword for place")
            return
        }
        if managedObjectContext != nil && !nameTextView.text.isEmpty && nameTextView.text != "Task" {
            let taskEntityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedObjectContext!)
            if let entityDescription = taskEntityDescription {
                let newTask = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext!)
                newTask.setValue(nameTextView.text, forKey: "name")
                let date = Calendar.current.startOfDay(for: datePicker.date)
                newTask.setValue(date, forKey: "date")
                newTask.setValue(moveTaskSwitch.isOn, forKey: "moveToNextDay")
                newTask.setValue(connectToPlaceSwitch.isOn, forKey: "isConnectedToPlace")
                if connectToPlaceSwitch.isOn {
                    if selectedTypeOfPlace != "-" {
                        newTask.setValue(selectedTypeOfPlace, forKey: "typeOfPlace")
                    }
                    if !(keywordForPlaceTextField.text?.isEmpty)! {
                        var keywordText = keywordForPlaceTextField.text!
                        keywordText = keywordText.replacingOccurrences(of: " ", with: "")
                        if let keyword = keywordText.applyingTransform(.toLatin, reverse: false) {
                            newTask.setValue(keyword, forKey: "keywordForPlace")
                        } else {
                            newTask.setValue(keywordText, forKey: "keywordForPlace")
                        }
                    }
                }
                do {
                    try newTask.managedObjectContext!.save()
                } catch {
                    showAlert(info: "Can't save new task")
                }
                navigationController?.popViewController(animated: true)
            } else {
                showAlert(info: "Can't save new task")
                return
            }
        } else if managedObjectContext != nil && (nameTextView.text.isEmpty || nameTextView.text == "Task") {
            showAlert(info: "Add name of the new task")
        } else if managedObjectContext == nil {
            showAlert(info: "Can't save new task")
        }
    }

    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if nameTextView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if nameTextView.text.isEmpty {
            textView.text = nameTextViewPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK:- PickerView Protocols
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typesOfPlaces.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typesOfPlaces[row]
    }
    
    func convertTypeOfPlaceString(str: String) -> String {
        let newStr = str.replacingOccurrences(of: " ", with: "_");
        return newStr.lowercased()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTypeOfPlace = convertTypeOfPlaceString(str: typesOfPlaces[row])
    }
    
    //MARK:- Keyboard notifications
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if keywordForPlaceTextField.isEditing {
                keyboardHeight = keyboardFrame.cgRectValue.height
                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight!, right: 0)
                scrollView.contentInset = contentInset
                scrollView.scrollIndicatorInsets = contentInset
                scrollView.setContentOffset(CGPoint(x: 0, y: 1.75*keyboardHeight!), animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if keyboardHeight != nil {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
            keyboardHeight = nil
        }
    }
}
