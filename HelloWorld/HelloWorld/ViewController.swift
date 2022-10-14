//
//  ViewController.swift
//  HelloWorld
//
//  Created by wiwi-git on 2022/10/14.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var helloLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sayButtonClicked(_ sender: NSButton) {
        var name = nameField.stringValue
        if name.isEmpty {
            name = "world"
        }
        
        let greeting = "Hello \(name)!"
        helloLabel.stringValue = greeting
    }
    
}

