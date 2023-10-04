//
//  ContentView.swift
//  Gym Counter Watch App
//
//  Created by Antonio Lucian on 03.10.2023.
//

/*
import SwiftUI

struct ContentView: View {
    
    @State private var numberOfRounds: Int = 1
    @State private var remainingTime: Int = 20 // 30 minutes 1800
    @State private var remainingPause: Int = 1 * 60 // 5 minutes 5*60
    
    @State var timer: Timer?
    
    @State private var isStarted: Bool = false;
    
    var body: some View {
        VStack {
            
            
            if self.remainingTime > 0 && self.numberOfRounds >= 1 && self.isStarted {
                Text("\(formatSecondsToMinutesAndSeconds(seconds: remainingTime))")
                    .font(.system(size: 40))
                    .bold()
                    .onAppear() {
                        startTimerForWorkout()
                        
                    }
                Text("Rounds: \(numberOfRounds)")
                    .font(.system(size: 24))
                    .padding()
                HStack {
                    
                    Button(action: {
                        self.numberOfRounds += 1
                        
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        if numberOfRounds > 1 {
                            self.numberOfRounds -= 1
                        }
                        
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    
                }
            } else if self.numberOfRounds >= 1 && self.remainingPause > 0 && self.isStarted {
                
                
                Text("\(formatSecondsToMinutesAndSeconds(seconds: remainingPause))").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 40))
                    .bold()
                    .onAppear() {
                        startTimerForPause()
                       // self.remainingTime = 1800
                    }
                
                Text("Rounds: \(numberOfRounds)")
                    .font(.system(size: 24))
                    .padding()
                HStack {
                    
                    Button(action: {
                        self.numberOfRounds += 1
                        
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        if numberOfRounds > 1 {
                            self.numberOfRounds -= 1
                        }
                        
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    
                }
            } else {
                Button("Start") {
                    self.isStarted = true
                    resetValues()
                }
            }
                    
                }
                .padding()
                .onDisappear() {
                            // Cancel the timer when the view disappears
                            self.timer?.invalidate()
                            self.timer = nil
                        }
        }
    
    func formatSecondsToMinutesAndSeconds(seconds: Int) -> String {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    
    func resetValues() -> Void {
      /*  self.remainingTime = 30 * 60
        self.remainingPause = 1 * 60 */
        self.numberOfRounds = 1
        self.remainingTime = 20 // 30 minutes 1800
        self.remainingPause = 1 * 60
    }
    
    func startTimerForWorkout() {
            // Cancel the previous timer
            self.timer?.invalidate()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    // Do other actions like transitioning to pause, etc.
                    self.timer?.invalidate() // Invalidate the timer when done
                }
            }
        }
        
        func startTimerForPause() {
            // Cancel the previous timer
            self.timer?.invalidate()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.remainingPause -= 1
                if self.remainingPause <= 0 {
                    // Do other actions, if needed.
                    self.timer?.invalidate() // Invalidate the timer when done
                }
            }
        }
    }

#Preview {
    ContentView()
}
 */

import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var remainingTime: Int = 20
    @Published var remainingPause: Int = 1 * 60
    @Published var numberOfRounds: Int = 1
    @Published var isStarted: Bool = false

    var timer: Timer?

    func startTimerForWorkout() {
        stopTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingTime -= 1
            if self.remainingTime <= 0 {
                self.numberOfRounds -= 1
                self.remainingPause = 1 * 60
                if self.numberOfRounds > 0 {
                    self.startTimerForPause()
                } else {
                    self.stopTimer()
                    self.isStarted = false
                }
            }
        }
    }

    func startTimerForPause() {
        stopTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingPause -= 1
            if self.remainingPause <= 0 {
                self.remainingTime = 20
                self.startTimerForWorkout()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopTimer()
    }
}

struct ContentView: View {
    @ObservedObject var timerManager = TimerManager()

    var body: some View {
        VStack {
            if timerManager.remainingTime > 0 && timerManager.numberOfRounds >= 1 && timerManager.isStarted {
                Text(formatSecondsToMinutesAndSeconds(seconds: timerManager.remainingTime))
                    .font(.system(size: 40))
                    .bold()
                    .onAppear() {
                        timerManager.startTimerForWorkout()
                    }
                
                Text("Rounds: \(timerManager.numberOfRounds)")
                    .font(.system(size: 24))
                    .padding()
                HStack {
                    Button(action: {
                        timerManager.numberOfRounds += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }

                    Button(action: {
                        if timerManager.numberOfRounds > 1 {
                            timerManager.numberOfRounds -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                }
            } else if timerManager.numberOfRounds >= 1 && timerManager.remainingPause > 0 && timerManager.isStarted {
                Text(formatSecondsToMinutesAndSeconds(seconds: timerManager.remainingPause))
                    .font(.system(size: 40))
                    .bold()
                    .foregroundColor(.blue)
                    .onAppear() {
                        timerManager.startTimerForPause()
                    }
                
                Text("Rounds: \(timerManager.numberOfRounds)")
                    .font(.system(size: 24))
                    .padding()
                HStack {
                    Button(action: {
                        timerManager.numberOfRounds += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }

                    Button(action: {
                        if timerManager.numberOfRounds > 1 {
                            timerManager.numberOfRounds -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                }
            } else {
                Button("Start") {
                    timerManager.isStarted = true
                    timerManager.numberOfRounds = 1
                    timerManager.remainingPause = 0
                    timerManager.remainingTime = 1 * 60
                    timerManager.startTimerForWorkout()
                }
            }
        }
        .padding()
        .onDisappear() {
            timerManager.stopTimer()
        }
    }

    func formatSecondsToMinutesAndSeconds(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

