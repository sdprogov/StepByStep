//
//  SegmentedControllerView.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import SwiftUI

/// A `SegmentedControllerView`
/// - TODO Exercise called for two `Buttons` but this seemed more natural to me
/// Instead of reusing the other `Segmented Controller`, created a new one to keep it more visually appealing
struct SegmentedControllerView: View {
	@Binding var selectedSegment: Int

	let options: [String]

	var body: some View {
		VStack {
			Picker("Options", selection: $selectedSegment) {
				ForEach(Array(options.enumerated()), id: \.element) {
					index, item in
					Text(item).tag(index)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding()
			.background(Color.white)  // Background color for the segmented control
			.cornerRadius(10)  // Rounded corners
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.blue, lineWidth: 2)  // Border color and width
			)
			.padding()  // Additional padding around the control
		}
	}
}

#Preview {
	NavigationStack {
		SegmentedControllerView(
			selectedSegment: .constant(0),
			options: ["Option 1", "Option 2", "Option 3"])
	}
}
