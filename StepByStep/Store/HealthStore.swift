//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import HealthKit
import Observation

/// A protocol that defines what a Health Store will be responsible for handling
protocol HealthStoreProtocol: Observable, AnyObject {
	var steps: [Step] { get }
	var error: HealthError? { get }
	func calculateSteps() async
	func requestAuthorization() async
}

enum HealthError {
	case healthDataNotAvailable(String)
}

extension HealthError: UserFacingErrorProtocol {
	var userFacingMessage: String {
		switch self {
		case .healthDataNotAvailable(let error):
			return "Health data is not available with error: \(error)"
		}
	}

	var id: String {
		userFacingMessage
	}
}

/// The Mock version of the Health Store, mocks `Step` data versus fetching from `HKHealthStore`
@Observable
class MockHealthStore: ViewContextModel<HealthError>, HealthStoreProtocol {

	var steps: [Step] = []
	private var currentSteps: Int = 0
	/// Setting this as the maximum number of steps it will fetch
	private let maxSteps: Int = 12500

	override init() {
		super.init()
		steps = []
	}
	
	/// Increments total number of steps by 100 every `0.5` seconds
	func calculateSteps() async {
		// Simulate slowly incrementing steps
		while currentSteps < maxSteps {
			// Simulate a delay
			do {
				try await Task.sleep(nanoseconds: 500_000_000)  // Sleep for 0.5 seconds

				// Increment steps
				currentSteps += 100  // Increment by 100 steps
				steps.append(Step(count: currentSteps, date: Date()))
				print("Steps count: \(steps.count)")
			} catch {
				// This is used for completion purposes, should never be triggered
				self.error = HealthError.healthDataNotAvailable(
					error.localizedDescription)
			}
		}
	}

	func requestAuthorization() async {
		// Mock implementation, no action needed for testing
	}
}

/// The Health Store that fetches directly from `HKHealthStore`
@Observable
class HealthStore: ViewContextModel<HealthError>, HealthStoreProtocol {

	var steps: [Step] = []
	var healthStore: HKHealthStore?

	override init() {
		super.init()
		if HKHealthStore.isHealthDataAvailable() {
			healthStore = HKHealthStore()
		} else {
			error = HealthError.healthDataNotAvailable(
				"Could not access HealthKit")
		}
	}

	deinit {
		calculateStepsTask?.cancel()
		calculateStepsTask = nil
	}

	/// Interval defining time period it will fetch, currently set to 5 minutes `(60 * 5)`
	private let calculateStepsInterval: Int = (60 * 5)  // 5 minutes
	/// The task for fetching periodically from `HKHealthStore`
	private var calculateStepsTask: Task<Void, any Error>? = nil
	
	/// Is called every time `HKHealthStore` is queried
	/// - Parameter healthStore: `HKHealthStore`
	private func monitorSteps(healthStore: HKHealthStore) {
		guard calculateStepsTask == nil else { return }
		calculateStepsTask = Task { @MainActor in
			for try await _ in TickGenerator(.seconds(calculateStepsInterval)) {
				await updateSteps(healthStore: healthStore)
			}
		}
	}
	
	/// Takes the data from `HKHealthStore` and transforms it into an array of `Step` which is used by the UI
	/// - Parameter healthStore: <#healthStore description#>
	private func updateSteps(healthStore: HKHealthStore) async {
		let calendar = Calendar(identifier: .gregorian)
		let startDate = calendar.date(byAdding: .day, value: -7, to: Date())
		let endDate = Date()

		let stepType = HKQuantityType(.stepCount)
		let everyDay = DateComponents(day: 1)
		let thisWeek = HKQuery.predicateForSamples(
			withStart: startDate, end: endDate)
		let stepsThisWeek = HKSamplePredicate.quantitySample(
			type: stepType, predicate: thisWeek)

		let sumOfStepsQuery = HKStatisticsCollectionQueryDescriptor(
			predicate: stepsThisWeek, options: .cumulativeSum,
			anchorDate: endDate, intervalComponents: everyDay)

		do {
			let stepsCount = try await sumOfStepsQuery.result(for: healthStore)

			guard let startDate = startDate else {
				self.error = HealthError.healthDataNotAvailable(
					"Data was missing date")
				return
			}

			stepsCount.enumerateStatistics(from: startDate, to: endDate) {
				statistics, stop in
				let count = statistics.sumQuantity()?.doubleValue(for: .count())
				let step = Step(
					count: Int(count ?? 0), date: statistics.startDate)
				if step.count > 0 {
					// add the step in steps collection
					self.steps.append(step)
				}
			}
		} catch {
			self.error = HealthError.healthDataNotAvailable(
				error.localizedDescription)
		}
	}

	/// When called will get steps from `HKHealthStore` and setup a monitor to re-check every 5 minutes
	/// Probably should be renamed
	func calculateSteps() async {

		isLoading = true
		guard let healthStore = self.healthStore else {
			self.error = HealthError.healthDataNotAvailable(
				"Could not load Health Kit")
			isLoading = false
			return
		}

		// Sets up the monitor at the end of the funcation call
		defer {
			// Continuously pull steps every 5 minutes
			monitorSteps(healthStore: healthStore)
		}

		await updateSteps(healthStore: healthStore)
		isLoading = false
	}
	
	/// Requests permission from the `HKHealthStore` to pull user data
	func requestAuthorization() async {

		isLoading = true

		guard
			let stepType = HKQuantityType.quantityType(
				forIdentifier: HKQuantityTypeIdentifier.stepCount)
		else { return }
		guard let healthStore = self.healthStore else { return }

		do {
			try await healthStore.requestAuthorization(
				toShare: [], read: [stepType])
			isLoading = false
		} catch {
			self.error = HealthError.healthDataNotAvailable(
				error.localizedDescription)
			isLoading = false
		}

	}

}

/// Makes the `HealthStore` injectable
private struct HealthStoreProviderKey: InjectionKey {
	static var currentValue: HealthStoreProtocol = StepsAppContext.shared
		.appHealthStore
}

extension InjectedValues {
	var healthStore: HealthStoreProtocol {
		get { Self[HealthStoreProviderKey.self] }
		set { Self[HealthStoreProviderKey.self] = newValue }
	}
}
