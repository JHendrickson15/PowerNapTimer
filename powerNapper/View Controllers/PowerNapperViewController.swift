//
//  PowerNapperViewController.swift
//  powerNapper
//
//  Created by Jordan Hendrickson on 5/7/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit
import UserNotifications

class PowerNapViewController: UIViewController {
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var toggleTimerButton: UIButton!
    
    let myTimer = MyTimer()
    static let notificationIdentifier = "PowerNapAlarm"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer.delegate = self
    }
    
    func updateTimerLabel() {
        timeRemainingLabel.text = myTimer.timeAsString
    }
    
    func updateView() {
        updateTimerLabel()
        if myTimer.isOn {
            toggleTimerButton.setTitle("Cancel", for: .normal)
        } else {
            toggleTimerButton.setTitle("Power Nap", for: .normal)
        }
    }
    
    func presentAlertController() {
        let alertController = UIAlertController(title: "Wake Up!!!", message: "Your nap is over", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Sleep for a few more minutes... "
            textField.keyboardType = .numberPad
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let snoozeTimeText = alertController.textFields?.first?.text,
                let time = TimeInterval(snoozeTimeText) else { return }
            self.myTimer.startTimer(time: time)
            self.updateView()
        }
        alertController.addAction(dismissAction)
        alertController.addAction(snoozeAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func toggleTimerButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
            cancelUserNotification()
        }else {
            myTimer.startTimer(time: 5)
            scheduleUserNotification()
        }
        updateView()
    }
}

//4) Adopt the Protocol
extension PowerNapViewController: MyTimerDelegate {
    
    //5) Implement Delegate Methods
    func timerSecondTicked() {
        updateTimerLabel()
    }
    
    func timerCompleted() {
        updateView()
        presentAlertController()
    }
    
    func timerStopped() {
        updateView()
    }
}

extension PowerNapViewController {
    
    func scheduleUserNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Wake Up!"
        content.body = "Time To Get Up!"
        guard let timeRemaining = myTimer.timeRemaining else {return}
        let fireDate = Date(timeInterval: timeRemaining, since: Date())
        let dateComponents = Calendar.current.dateComponents([.minute , .second], from: fireDate)
        let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: PowerNapViewController.notificationIdentifier, content: content, trigger: dateTrigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to schedule local notification request: \(error) : \(error.localizedDescription)")
            }
        }
    }
    func cancelUserNotification(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [PowerNapViewController.notificationIdentifier])
    }
}

