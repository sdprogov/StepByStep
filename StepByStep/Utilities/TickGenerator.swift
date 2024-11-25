//
//  TickGenerator.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// `TickGenerator` will `async` loop through a `Sequence`, waiting the specified `Duration`
struct TickGenerator: AsyncSequence, AsyncIteratorProtocol {
	typealias Element = Int

	var duration: Duration
	private(set) var tick = 0

	init(_ duration: Duration) { self.duration = duration }
	func makeAsyncIterator() -> Self { self }

	mutating func next() async throws -> Element? {
		try await Task.sleep(for: duration)
		guard !Task.isCancelled else { return nil }

		tick += 1
		return tick
	}
}
