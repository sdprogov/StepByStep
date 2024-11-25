//
//  StepsStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import Observation

/// Protocol for the `StepsStore` defining what it will do
protocol StepsStoreProtocol: Observable, AnyObject {
	var totalStepsLastWeek: TotalStepsByDay { get }
	var totalStepsLastMonth: TotalStepsByDay { get }
	func fetch()
}

/// `MockStepsStore` uses generated data to simulate live data
@Observable
class MockStepsStore: ViewContextModel<StepsFetchError>, StepsStoreProtocol {

	var totalStepsLastWeek: TotalStepsByDay = []
	var totalStepsLastMonth: TotalStepsByDay = []

	private let fetcher = MockStepsFetcher()

	private var stepsHistory: [StepData] = [] {
		didSet {
			totalStepsLastWeek = stepsHistory.totalSteps(forLastDays: 7)
			totalStepsLastMonth = stepsHistory.totalSteps(forLastDays: 30)
		}
	}

	func fetch() {
		isLoading = true
		Task { @MainActor in
			do throws(StepsFetchError) {
				self.stepsHistory = try await self.fetcher.fetchSteps()
				self.isLoading = false
			} catch {
				self.error = error
				self.isLoading = false
			}
		}
	}
}

/// `StepsStore` that fetches `Step` data from API
@Observable
class StepsStore: ViewContextModel<StepsFetchError>, StepsStoreProtocol {
	var totalStepsLastWeek: TotalStepsByDay = []
	var totalStepsLastMonth: TotalStepsByDay = []

	private let fetcher = StepsFetcher()
	private var stepsHistory: [StepData] = [] {
		didSet {
			totalStepsLastWeek = stepsHistory.totalSteps(forLastDays: 7)
			totalStepsLastMonth = stepsHistory.totalSteps(forLastDays: 30)
		}
	}

	func fetch() {
		isLoading = true
		Task { @MainActor in
			do {
				self.stepsHistory = try await self.fetcher.fetchSteps()
				self.isLoading = false
			} catch let error as StepsFetchError {
				self.error = error
				self.isLoading = false
			} catch {
				self.error = StepsFetchError.unknown(error: error.localizedDescription)
				self.isLoading = false
			}
		}
	}
}

/// Makes `StepsStore` injectable
private struct StepsStoreProviderKey: InjectionKey {
	static var currentValue: StepsStoreProtocol = StepsAppContext.shared.appStepsStore
}

extension InjectedValues {
	var stepsStore: StepsStoreProtocol {
		get { Self[StepsStoreProviderKey.self] }
		set { Self[StepsStoreProviderKey.self] = newValue }
	}
}
