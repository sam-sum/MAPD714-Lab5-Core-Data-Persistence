//
//  ViewController.swift
//  Core Data Persistence
//
//  Created by Samuel Sum on 2022-11-18.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    private static let lineEntityName = "Line"
    private static let lineNumberKey = "lineNumber"
    private static let lineTextKey = "lineText"
    
    @IBOutlet var lineFields:[UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ViewController.lineEntityName)
        do {
            let objects = try context.fetch(request)
            for object in objects {
                let lineNum: Int = (object as AnyObject).value(forKey: ViewController.lineNumberKey)! as! Int
                let lineText = (object as AnyObject).value(forKey: ViewController.lineTextKey) as? String ?? ""
                let textField = lineFields[lineNum]
                textField.text = lineText
            }
            
            let app = UIApplication.shared
            NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(notification:)),
                   name: UIApplication.willResignActiveNotification, object: app)
        } catch {
            // Error thrown from executeFetchRequest()
          print("There was an error in executeFetchRequest(): \(error)")
        }
    }
    
    @objc func applicationWillResignActive(notification:Notification) {
        print("Running func applicationWillResignActive")
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        for i in 0 ..< lineFields.count {
            let textField = lineFields[i]
            
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ViewController.lineEntityName)
            let pred = NSPredicate(format: "%K = %d", ViewController.lineNumberKey, i)
            request.predicate = pred
            
            do {
                let objects = try context.fetch(request)
                var theLine:NSManagedObject! = objects.first as? NSManagedObject
                if theLine == nil {
                    // No existing data for this row – insert a new managed object for it
                    theLine =
                        NSEntityDescription.insertNewObject(
                            forEntityName: ViewController.lineEntityName,
                            into: context)
                        as NSManagedObject
                }
                theLine.setValue(i, forKey: ViewController.lineNumberKey)
                theLine.setValue(textField.text, forKey: ViewController.lineTextKey)
            } catch {
                print("There was an error in executeFetchRequest(): \(error)")
            }
        }
        appDelegate.saveContext()
    }
}

