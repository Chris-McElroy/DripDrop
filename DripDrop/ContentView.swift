//
//  ContentView.swift
//  DripDrop
//
//  Created by Chris McElroy on 12/15/22.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.scenePhase) var scenePhase
	
	@State var logHistory: [String: Double] = Storage.dictionary(.logHistory) as? [String: Double] ?? [:]
	@State var goalHistory: [String: Double] = Storage.dictionary(.goalHistory) as? [String: Double] ?? [:]
	@State var defaultSize: Double = Storage.double(.defaultSize)
	@State var dayStart: Double = Double(Storage.int(.dayStart))
	@State var dayEnd: Double = Double(Storage.int(.dayEnd))
	@State var loggedToday: Double = 0
	@State var goal: Double = 60
	@State var settingsView: Bool = false
	
    var body: some View {
        VStack {
			Spacer()
			if settingsView {
				Text("settings")
				Spacer()
				Text("reset today")
					   .onTapGesture {
						   loggedToday = 0
						   logHistory[String(Date.int)] = loggedToday
						   Storage.set(logHistory, for: .logHistory)
					   }
			   Spacer()
				VStack {
					Text("drink size")
					Text(String(format: "%.1f", defaultSize))
					Slider(value: $defaultSize, in: 0...24, step: 0.5, onEditingChanged: { _ in
						Storage.set(defaultSize, for: .defaultSize)
					})
					VStack {
						Text("start of the day")
						Text(doubleToTime(dayStart))
						Slider(value: $dayStart, in: 0...1440, step: 15, onEditingChanged: { _ in
							Storage.set(Int(dayStart), for: .dayStart)
							updateLogAndGoal()
						})
						Text("end of the day")
						Text(doubleToTime(dayEnd))
						Slider(value: $dayEnd, in: 0...1440, step: 15, onEditingChanged: { _ in
							Storage.set(Int(dayEnd), for: .dayEnd)
							updateLogAndGoal()
						})
					}
					Text("goal")
					Text(String(format: "%.1f", goal))
					Slider(value: $goal, in: 0...120, step: 5, onEditingChanged: { _ in
						goalHistory[String(Date.int)] = goal
						Storage.set(goalHistory, for: .goalHistory)
					})
				}
				Spacer()
				Text("exit")
					.onTapGesture {
						settingsView = false
					}
			} else {
				Spacer()
				Text(currentProgressString())
				Spacer().frame(height: 50)
				VStack {
					Image("water3")
						.resizable()
						.scaledToFit()
						.frame(height: 120)
					// Liquid icons created by Roundicons
					// https://www.flaticon.com/free-icons/liquid
					Text("add \(defaultSize.toString()) oz drink")
				}
					.onTapGesture {
						loggedToday += defaultSize
						logHistory[String(Date.int)] = loggedToday
						Storage.set(logHistory, for: .logHistory)
					}
				Spacer().frame(height: 50)
				Text(encouragementString())
			}
			Spacer()
			HStack {
				Image(systemName: "gear")
					.resizable()
					.scaledToFit()
					.frame(height: 20)
					.onTapGesture {
						settingsView.toggle()
					}
				Spacer()
			}
			
        }
        .padding()
		.background(getCurrentColor())
		.onAppear {
			updateLogAndGoal()
		}
		.onChange(of: scenePhase, perform: { newPhase in
			if newPhase == .active {
				updateLogAndGoal()
			}
		})
		.foregroundColor(.white)
    }
	
	func updateLogAndGoal() {
		print("hi")
		if let currentLog = logHistory[String(Date.int)] {
			loggedToday = currentLog
		} else {
			loggedToday = 0
			logHistory[String(Date.int)] = loggedToday
			Storage.set (logHistory, for: .logHistory)
		}
		
		if let currentGoal = goalHistory[String(Date.int)] {
			goal = currentGoal
		} else {
			goal = Double(goalHistory.max(by: { $0.key > $1.key })?.value ?? 60)
			goalHistory[String(Date.int)] = goal
			Storage.set(goalHistory, for: .goalHistory)
		}
	}
	
	func currentProgressString() -> String {
		return "\(loggedToday.toString()) / \(goal.toString()) oz"
	}
	
	func encouragementString() -> String {
		guard let fraction = getCurrentFraction() else {
			return "sleep time!"
		}
		
		if loggedToday >= goal {
			return "you hit your goal!"
		}
		if loggedToday == 0 {
			return "time for some water!"
		}
		
		let progress = loggedToday/(goal*fraction + 0.0001)
		
		if progress >= 1 {
			return "you're on track!"
		}
		
		if progress > 0.7 {
			return "nearly there!"
		}
		
		return "gotta catch up!"
	}
	
	func getCurrentFraction() -> Double? {
		let time = Double(Date.min)
		
		if dayEnd < dayStart {
			if time > dayEnd && time < dayStart {
				return nil
			}
			if time <= dayEnd {
				return Double(time + 1440 - dayStart)/Double(dayEnd + 1440 - dayStart)
			} else {
				return Double(time - dayStart)/Double(dayEnd + 1440 - dayStart)
			}
		} else {
			if time < dayStart || time > dayEnd {
				return nil
			}
			return Double(time - dayStart)/Double(dayEnd - dayStart)
		}
	}
	
	func getCurrentColor() -> Color {
		guard let fraction = getCurrentFraction() else { return .black }
		
		let localGoal = goal*fraction + 0.0001
		
		return Color(red: max(min(1 - pow((loggedToday/localGoal), 5), 1), 0), green: 0.8*max(min(pow(loggedToday/localGoal, 0.7), 1), 0), blue: 0)
	}
	
	func doubleToTime(_ time: Double) -> String {
		var hours = Int(time/60) % 12
		if hours == 0 { hours = 12 }
		let minutes = Int(time.truncatingRemainder(dividingBy: 60))
		let pm = time.truncatingRemainder(dividingBy: 1440) >= 720
		return String(format: "%d:%02d \(pm ? "pm" : "am")", hours, minutes)
	}
}

extension Double {
	func toString() -> String {
		let format = NumberFormatter()
		format.maximumFractionDigits = 2
		format.minimumFractionDigits = 0
		return format.string(from: self as NSNumber) ?? ""
	}
}

extension Date {
	func isYesterday() -> Bool {
		Calendar.current.isDateInYesterday(self)
	}
	
	func isToday() -> Bool {
		Calendar.current.isDateInToday(self)
	}
	
	static var int: Int {
		let dayStart = Storage.int(.dayStart)
		let dayEnd = Storage.int(.dayEnd)
		let int = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
		if (dayStart > dayEnd) && (min < dayEnd) {
			return int - 1
		} else if dayStart < dayEnd && min > dayEnd {
			return int + 1
		}
		return int
	}
	
	static var min: Int {
		return Calendar.current.ordinality(of: .minute, in: .day, for: Date()) ?? 0
	}
	
	static var now: TimeInterval {
		timeIntervalSinceReferenceDate
	}
	
	static var ms: Int {
		Int(now*1000)
	}
}
