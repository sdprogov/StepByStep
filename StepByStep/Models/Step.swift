//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftData

/// `StepRecord` is a `@Model` and is stored locally by `SwiftData`
@Model class StepRecord: Identifiable {
	private(set) var id: UUID
	private(set) var count: Int
	private(set) var date: Date
	var isSynced: Bool = false

	public init(step: Step) {
		self.id = step.id
		self.count = step.count
		self.date = step.date
	}

	var step: Step {
		Step(id: id, count: count, date: date)
	}
}

/// `Step` is a model that comes directly from `HKHealthKit`
struct Step: Identifiable {
	let id: UUID
    let count: Int
    let date: Date

	public init(
		id: UUID = UUID(),
		count: Int,
		date: Date
	) {
		self.id = id
		self.count = count
		self.date = date
	}

}

/// Extends `Step` so it conforms to `Hashable` and `Equatable`.
/// Uses its `id` which should be unique for both `Hashing` and `Equatable` purposes
/// Probably incorporate other properties in the hasher and equality to prevent collisions
extension Step: Hashable {
	static func == (lhs: Step, rhs: Step) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		self.id.hash(into: &hasher)
	}
}
