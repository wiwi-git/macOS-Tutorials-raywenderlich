//
//  ViewController.swift
//  EggTimer
//
//  Created by wiwi on 2022/10/14.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var timeLeftField: NSTextField!
    @IBOutlet weak var eggImageView: NSImageView!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    
    var eggTimer = EggTimer()
    var prefs = Preferences()
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        eggTimer.delegate = self
        setupPrefs()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "PrefsChanged"), object: nil, queue: nil) { _ in
            self.checkForResetAfterPrefsChange()
        }
    }
    
    func updateFromPrefs() {
        self.eggTimer.duration = self.prefs.selectedTime
        self.resetButtonClicked(self)
    }
    
    func checkForResetAfterPrefsChange() {
        if eggTimer.isStopped || eggTimer.isPaused {
            updateFromPrefs()
        } else {
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning

            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
    func configureButtonsAndMenus() {
      let enableStart: Bool
      let enableStop: Bool
      let enableReset: Bool

      if eggTimer.isStopped {
        enableStart = true
        enableStop = false
        enableReset = false
      } else if eggTimer.isPaused {
        enableStart = true
        enableStop = false
        enableReset = true
      } else {
        enableStart = false
        enableStop = true
        enableReset = false
      }

      startButton.isEnabled = enableStart
      stopButton.isEnabled = enableStop
      resetButton.isEnabled = enableReset

      if let appDel = NSApplication.shared.delegate as? AppDelegate {
        appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
      }
    }
    
    @IBAction func startButtonClicked(_ sender: Any) {
        if eggTimer.isPaused {
            eggTimer.resumeTimer()
        } else {
            eggTimer.duration = prefs.selectedTime
            eggTimer.startTimer()
        }
        configureButtonsAndMenus()
        prepareSound()
    }
    
    
    @IBAction func stopButtonClicked(_ sender: Any) {
        eggTimer.stopTimer()
        configureButtonsAndMenus()
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        eggTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
    
    // MARK: - IBActions - menus

    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
      startButtonClicked(sender)
    }

    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
      stopButtonClicked(sender)
    }

    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
      resetButtonClicked(sender)
    }
       

}

extension ViewController: EggTimerProtocol {
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval) {
        updateDisplay(for: timeRemaining)
    }
    
    func timerHasFinished(_ timer: EggTimer) {
        updateDisplay(for: 0)
        configureButtonsAndMenus()
        playSound()
    }
}
extension ViewController {
    
    // MARK: - Display
    
    func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Done!"
        }
        
        let minutesRemaining = floor(timeRemaining / 60)
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        
        let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        return timeRemainingDisplay
    }
    
    func imageToDisplay(for timeRemaining: TimeInterval) -> NSImage? {
        let percentageCompplete = 100 - (timeRemaining / 360 * 100)
        
        if eggTimer.isStopped {
            let stoppedImageName = (timeRemaining == 0) ? "100" : "stopped"
            return NSImage(named: stoppedImageName)
        }
        
        let imageValue: Int
        switch percentageCompplete {
        case 0 ..< 25: imageValue = 0
        case 25 ..< 50: imageValue = 25
        case 50 ..< 75: imageValue = 50
        case 75 ..< 100: imageValue = 75
        default: imageValue = 100
        }
        
        return NSImage(named: "\(imageValue)")
    }
    
    func updateDisplay(for timeRemaining: TimeInterval) {
        timeLeftField.stringValue = textToDisplay(for: timeRemaining)
        eggImageView.image = imageToDisplay(for: timeRemaining)
    }
}
extension ViewController {
    func prepareSound () {
        guard let audioFileUrl = Bundle.main.url(forResource: "ding", withExtension: "mp3") else { return }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    func playSound() {
        soundPlayer?.play()
    }
}
