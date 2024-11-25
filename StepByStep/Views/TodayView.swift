//
//  AuthStore.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import SwiftUI

/// `TodayView` shows all `Step` data for `Today`
/// - TODO Exercise also called for a `BarGraph` but I did not understand
/// in which context, or what `Data` would be used there
struct TodayView: View {

	private enum Constants {
		static let goal: Int = 10000  // 10,000 daily step goal
		static let barHeight: CGFloat = 60
		static let cornerRadius: CGFloat = 15
	}

	let step: Step

	/// Progress, if `step.count` > `goal` just shows as 100% progress
	var progress: Double {
		min(Double(step.count) / Double(Constants.goal), 1.0)
	}

	var body: some View {
		todayView
	}

	private var progressColor: Color {
		if underHalfwayToGoal(step.count) {
			return Color.red
		} else if isUnderGoal(step.count) {
			return Color.blue
		} else {
			return Color.green
		}
	}

	@ViewBuilder
	private var todayView: some View {
		VStack {
			stepsSummaryView
			stepsProgressView
		}
	}

	/// A summary of all Steps
	@ViewBuilder
	private var stepsSummaryView: some View {
		VStack {
			Text("\(step.count)")
				.font(.largeTitle)
		}.frame(maxWidth: .infinity, maxHeight: 150)
			.background(.orange)
			.clipShape(
				RoundedRectangle(
					cornerRadius: Constants.cornerRadius, style: .continuous)
			)
			.overlay(alignment: .topLeading) {
				HStack {
					Image(systemName: "flame")
						.foregroundStyle(.red)
					Text("Steps")
				}.padding()
			}
			.overlay(alignment: .bottomTrailing) {
				Text(step.date.formatted(date: .abbreviated, time: .omitted))
					.font(.caption)
					.padding()
			}
	}

	/// Progress bar indicating progress to `Goal`
	@ViewBuilder
	private var stepsProgressView: some View {
		VStack(alignment: .trailing) {
			RoundedRectangle(cornerRadius: Constants.cornerRadius)
				.frame(height: Constants.barHeight)  // Height of the progress bar
				.foregroundColor(Color.gray.opacity(0.3))  // Background color
				.overlay(
					GeometryReader { geometry in
						RoundedRectangle(cornerRadius: Constants.cornerRadius)
							.frame(
								width: progress * geometry.size.width,
								height: Constants.barHeight
							)  // Width based on progress
							.foregroundColor(progressColor)  // Progress color
							.animation(
								.easeInOut(duration: 0.5), value: progress)  // Animation
					}
				)
			Text("10,000 Steps")
				.font(.caption)
		}
		.padding(.vertical)
	}
}

#Preview {
	NavigationStack {
		TodayView(step: .init(count: 5000, date: Date()))
	}
}
