//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import SwiftData
import SwiftUI

enum DisplayType: Int, Identifiable, CaseIterable {

	case today
	case history

	var id: Int {
		rawValue
	}
}

extension DisplayType {

	var icon: String {
		switch self {
		case .today:
			return "figure.walk"
		case .history:
			return "chart.bar"
		}
	}
}

/// The Main Tab View
/// Allows user to Toggle between `Today` and `History
/// Exercise called for Text, I used Icons instead
struct HomeView: View {

	@Injected(\.healthStore) var healthStore: HealthStoreProtocol

	@State private var displayType: DisplayType = .today
	@State private var syncManager: SyncableManagerProtocol? = nil
	@State var steps: [Step] = []

	@ViewBuilder
	var tabView: some View {
		VStack {
			Picker("Selection", selection: $displayType) {
				ForEach(DisplayType.allCases) { displayType in
					Image(systemName: displayType.icon).tag(displayType)
				}
			}
			.pickerStyle(.segmented)

			switch displayType {
			case .today:
				if let step = steps.first {
					TodayView(step: step)
				} else {
					// TODO: empty state view
					EmptyView()
				}

			case .history:
				StepsChartView()
			}

			Spacer()

		}
		.padding()
	}

	/// This is mostly unnecessary, but decided to be safe to prevent duplicate `Step` from being added
	/// - TODO refactor out of the `View` does not belong here
	private func processSteps(old: [Step], new: [Step]) {
		steps = healthStore.steps.sorted { lhs, rhs in
			lhs.date > rhs.date
		}
		Task { @MainActor in
			if syncManager == nil {
				syncManager = SyncManager.shared()
			}
			let oldSet = Set(old)
			let newSet = Set(new)
			let difference = newSet.subtracting(oldSet)
			let uniqueSteps = Array(difference)
			try? await syncManager?.saveSteps(steps: uniqueSteps)
		}
	}

	var body: some View {
		tabView
			.listenForViewContextChanges(
				viewContext: ViewContext(viewName: "Home View") // Both Tabs have same `ViewContext` TODO: refactor so each tab has its own `ViewContext`
			)
			.navigationTitle("Step by Step")
			.onChange(of: healthStore.steps) { old, new in
				processSteps(old: old, new: new)
			}
			.task {
				await healthStore.requestAuthorization()
				await healthStore.calculateSteps()
			}
	}
}

#Preview {
	NavigationStack {
		HomeView()
	}
}
