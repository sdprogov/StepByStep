//
//  StepData.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// A model that is used for uploading and fetching step data from the `API`
struct StepData: Codable {
	let id: Int
	let username: String
	let stepsDate: String
	let stepsDatetime: String
	let stepsCount: Int
	let stepsTotalByDay: Int

	static let dateFormatter = ISO8601DateFormatter()

	public init(
		id: Int,
		username: String,
		stepsDate: String,
		stepsDatetime: String = "",
		stepsCount: Int,
		stepsTotalByDay: Int = 0
	) {
		self.id = id
		self.username = username
		self.stepsDate = stepsDate
		self.stepsDatetime = stepsDatetime
		self.stepsCount = stepsCount
		self.stepsTotalByDay = stepsTotalByDay
	}

	enum CodingKeys: String, CodingKey {
		case id
		case username
		case stepsDate = "steps_date"
		case stepsDatetime = "steps_datetime"
		case stepsCount = "steps_count"
		case stepsTotalByDay = "steps_total_by_day"
	}

	var date: Date? {
		StepData.dateFormatter.date(from: stepsDate)
	}
}
