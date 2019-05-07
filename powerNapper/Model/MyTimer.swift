//
//  MyTimer.swift
//  powerNapper
//
//  Created by Jordan Hendrickson on 5/7/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import Foundation


//1) Write the Protocol
protocol MyTimerDelegate: class {
    func timerSecondTicked()
    func timerCompleted()
    func timerStopped()
}

class MyTimer: NSObject {
    
    var timeRemaining: TimeInterval?
    var timer: Timer?
    
    //2) delcare weak var delegate
    weak var delegate: MyTimerDelegate?
    
    var isOn: Bool {
        return timeRemaining != nil
    }
    
    var timeAsString: String {
        let timeRemaining = Int(self.timeRemaining ?? 20 * 60)
        let minutesRemaining = timeRemaining / 60
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        return String(format: "%02d : %02d", arguments: [minutesRemaining, secondsRemaining])
    }
    
    func secondTick() {
        guard let unwrappedCopyOfTimeRemaining = timeRemaining else { return }
        if unwrappedCopyOfTimeRemaining > 0 {
            timeRemaining = unwrappedCopyOfTimeRemaining - 1
            delegate?.timerSecondTicked()
            print(timeRemaining ?? 0)
        } else {
            timer?.invalidate()
            self.timeRemaining = nil
            delegate?.timerCompleted()
        }
    }
    
    func startTimer(time: TimeInterval) {
        if !isOn {
            timeRemaining = time
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                    self.secondTick()
                })
            }
        }
    }
    
    func stopTimer() {
        if isOn {
            timeRemaining = nil
            timer?.invalidate()
            delegate?.timerStopped()
        }
    }
}
