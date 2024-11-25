//
//  Array+Extensions.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

typealias TotalStepsByDay = [(day: Date, steps: Int)]

extension Array where Element == Step {
	
	/// Maps an Array of `STEP` to an array of `STEPData`
	/// Will group `[STEP]` by date, and get the total steps for that data
	/// - Parameter username: `String` required by the API
	/// - Returns: An array of `STEPData`
	func mapStepsToStepData(username: String) -> [StepData] {
		// Create a date formatter to extract the date part
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"

		// Group steps by their date (ignoring time)
		var groupedSteps: [String: [Step]] = [:]

		for step in self {
			let dateKey = dateFormatter.string(from: step.date)
			if groupedSteps[dateKey] != nil {
				groupedSteps[dateKey]?.append(step)
			} else {
				groupedSteps[dateKey] = [step]
			}
		}

		// Create StepData objects
		var stepDataArray: [StepData] = []
		var idCounter = 0

		for (dateKey, stepsForDate) in groupedSteps {
			let totalSteps = stepsForDate.reduce(stepsForDate[0]) { $0.count > $1.count ? $0 : $1 }.count
			let date = dateFormatter.date(from: dateKey) ?? Date()

			let stepData = StepData(
				id: idCounter,
				username: username,
				stepsDate: dateKey,
				stepsDatetime: StepData.dateFormatter.string(from: date),
				stepsCount: totalSteps,
				stepsTotalByDay: totalSteps
			)
			stepDataArray.append(stepData)
			idCounter += 1
		}

		return stepDataArray
	}
}

extension Array where Element == StepData {
	
	/// Generates mock `StepData`
	/// - Parameter count: `Int` representing the amount of `StepData` to be mocked
	/// - Returns: `[StepData]`
	static func generateMockData(count: Int) -> [StepData] {
		var mockData: [StepData] = []

		let calendar = Calendar.current

		for i in 0..<count {
			let stepsCount = Int.random(in: 1000...10000)
			let date = calendar.date(byAdding: .day, value: -Int.random(in: 0...30), to: Date())!
			let stepsDate = StepData.dateFormatter.string(from: date)
			mockData.append(StepData(id: i + 1, username: "User\(i % 5)", stepsDate: stepsDate, stepsCount: stepsCount))
		}

		return mockData
	}
	
	/// Will find the total steps walked over the specified time period
	/// - Parameter days: `Int`, eg if you want the total steps walked in the last 7 days, pass in 7
	/// - Returns: `TotalStepsByDay` will sort the steps by date, so if you pass in the last 2 days, will return steps on day 1 and day 2
	func totalSteps(forLastDays days: Int) -> TotalStepsByDay {
		var stepsByDate: [Date: Int] = [:]
		let calendar = Calendar.current

		// Get the date range
		let endDate = Date()
		guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else { return [] }


		// Filter and aggregate steps
		for step in self {
			if let stepsDate = step.date, stepsDate >= startDate {
				stepsByDate[stepsDate, default: 0] += step.stepsCount
			}
		}

		// Sort by date
		let sortedSteps = stepsByDate.sorted { $0.key < $1.key }

		return sortedSteps.map { (day: $0.key, steps: $0.value) }
	}
}
