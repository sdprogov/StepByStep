//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Charts
import SwiftUI

/// Returns a `String` from `Date` with `Day` and `Date` eg `Mon 13`
extension Date {
	func dayOfWeekAndDayOfMonth() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEE dd"  // "EEE" for abbreviated day of the week, "dd" for day of the month
		return dateFormatter.string(from: self)
	}
}

/// `StepsChartView` allows you to `visualize` the `Data` walked for the `last7Days` and `last30Days`
struct StepsChartView: View {

	enum HistoryOptions: Int {
		case last7Days = 0
		case last30Days = 1

		public init(rawValue: Int) {
			switch rawValue {
			case 0:
				self = .last7Days
			case 1:
				self = .last30Days
			default:
				self = .last7Days
			}
		}
	}

	@Injected(\.stepsStore) var stepStore: StepsStoreProtocol

	@State private var selectedHistory: Int = 0

	var body: some View {
		VStack {
			SegmentedControllerView(
				selectedSegment: $selectedHistory,
				options: ["Last 7 Days", "Last 30 Days"]
			)
			.padding()
			switch HistoryOptions(rawValue: selectedHistory) {
			case .last7Days:
				weekStepsChart
			case .last30Days:
				monthStepsChart
			}
		}
		.onAppear {
			stepStore.fetch()
		}
	}

	/// Week view
	@ViewBuilder
	private var weekStepsChart: some View {
		Chart {
			ForEach(stepStore.totalStepsLastWeek, id: \.day) { stepData in
				BarMark(
					x: .value("Date", stepData.day.dayOfWeekAndDayOfMonth()),
					y: .value("Steps Count", stepData.steps)
				)
				.foregroundStyle(isUnderGoal(stepData.steps) ? .red : .green)
			}
		}
		.padding()
	}

	/// Month View
	/// TODO Last 30 days is being equated by Month
	/// Can Refactor to pull last month worth of data whether that's 28,29,30 or 31 days
	@ViewBuilder
	private var monthStepsChart: some View {
		Chart {
			ForEach(stepStore.totalStepsLastMonth, id: \.day) { stepData in
				BarMark(
					x: .value("Date", stepData.day),
					y: .value("Steps Count", stepData.steps)
				)
				.foregroundStyle(isUnderGoal(stepData.steps) ? .red : .green)
			}
		}
		.padding()
	}
}

#Preview {
	NavigationStack {
		StepsChartView()
	}
}
