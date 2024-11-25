//
//  StepsSyncher.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation
import SwiftData
import Combine

/// A protocol for an object reponsible for keeping local `Step` data in sync with API
protocol SyncableManagerProtocol {
	func saveSteps(steps: [Step]) async throws(SyncableError)
	func uploadNoneSyncedItem() async throws(SyncableError)
	static func shared() async -> SyncableManagerProtocol
}

enum SyncableError {
	case recordNotFound
	case deletionFailed(String)
	case saveFailed(String)
	case fetchFailed(String)
	case uploadFailed(String)
}

extension SyncableError: UserFacingErrorProtocol {
	var userFacingMessage: String {
		switch self {
		case .recordNotFound:
			"Could not find record"
		case .deletionFailed(let error):
			"Deletion from local db failed with \(error)"
		case .saveFailed(let error):
			"Saving to local db failed with \(error)"
		case .fetchFailed(let error):
			"Fetching from local db failed with error \(error)"
		case .uploadFailed(let error):
			"Uploading to remote failed with error \(error)"
		}
	}
	
	var id: String {
		userFacingMessage
	}
	
}

/// A `MockSyncManager`
/// Does not connect to the API nor does it save data locally
@MainActor
final class MockSyncManager: SyncableManagerProtocol {
	private var steps: [Step] = []

	private let uploader = MockStepsUploader()

	private var uniqueValues: Set<Step> = []
	private var cancellables: Set<AnyCancellable> = []

	// Publisher to notify when a new unique item is added
	private let newValuePublisher = PassthroughSubject<Step, Never>()

	// Attempts to upload every 5 minutes
	private let uploadInterval: Int = (60 * 5)
	private var uploadTask: Task<Void, any Error>? = nil
	
	/// initializer
	/// On `init()` will listen for new values and create `uploadTask`
	/// Will upload items that are not synced every 5 minutes
	private init() {
		newValuePublisher.sink(receiveValue: { newValue in
			print("New step added: \(newValue)")
		}).store(in: &cancellables)

		uploadTask = Task {
			for try await _ in TickGenerator(.seconds(uploadInterval)) {
				do {
					try await uploadNoneSyncedItem()
				} catch {
					// Handle error here
				}
			}
		}
	}

	deinit {
		uploadTask?.cancel()
		uploadTask = nil
	}

	static func shared() -> SyncableManagerProtocol {
		return MockSyncManager()
	}

	/// Mocks saving steps to the `DB`
	func saveSteps(steps: [Step]) async throws(SyncableError) {
		for step in steps {
			guard uniqueValues.insert(step).inserted else { continue }
			try await saveStep(step: step)
			newValuePublisher.send(step)
		}
	}

	/// Mocks saving one `Step` to the `DB`
	private func saveStep(step: Step) async throws(SyncableError) {
		steps.append(step)
		let dbStep = StepRecord(step: step)
		try await appendRecord(record: dbStep)
	}

	private func appendRecord(record: StepRecord) async throws(SyncableError) {
		// Do nothing
	}

	private func fetchNoneSyncedItems() async throws(SyncableError) -> [StepRecord] {
		// Do nothing
		return []
	}

	private func removeItem(with id: UUID) async throws(SyncableError) {
		// Do nothing
	}

	/// Mocks uploading none synced items
	func uploadNoneSyncedItem() async throws(SyncableError) {
		let items = try await fetchNoneSyncedItems()

		let uploadableData = items.map { $0.step }.mapStepsToStepData(username: "user1@test.com")

		for uploadableItem in uploadableData {
			do {
				try await self.uploader.uploadStepData(stepData: uploadableItem)
			} catch {
				throw .uploadFailed(error.localizedDescription)
			}
		}

		for item in items {
			item.isSynced = true
		}
	}
}

/// `SyncManager` which saves `[Step]` to local `DB` using `SwiftData`
/// Due to getting 500 API error, this actually will not upload data, this was done so saving to `SwiftData` could be tested
/// TODO: when API is solved, change `uploader` to point to `StepsUploader`
@MainActor
final class SyncManager : SyncableManagerProtocol {
	private var steps: [Step] = []

	private let modelContainer: ModelContainer
	private let modelContext: ModelContext

	private let uploader = MockStepsUploader() // TODO: due to getting a 500 server error when uploading, leaving as a mock

	private var uniqueValues: Set<Step> = []
	private var cancellables: Set<AnyCancellable> = []

	// Publisher to notify when a new unique item is added
	private let newValuePublisher = PassthroughSubject<Step, Never>()

	private let uploadInterval: Int = (60 * 5)
	private var uploadTask: Task<Void, any Error>? = nil

	@MainActor
	private init() {
		do {
			/// Fetches a reference to `ModelContainer` from the `environment`
			self.modelContainer = try ModelContainer(for: StepRecord.self)
			self.modelContext = modelContainer.mainContext
		} catch {
			fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
		}

		/// Listens for new values
		newValuePublisher.sink(receiveValue: { newValue in
			print("New step added: \(newValue)")
		}).store(in: &cancellables)

		/// Will upload none synced items every 5 minutes
		/// TODO: currently points to a `Mock Uploader`
		uploadTask = Task {
			for try await tick in TickGenerator(.seconds(uploadInterval)) {
				print("Attempting to upload with attempt number: \(tick)")
				do {
					try await uploadNoneSyncedItem()
				} catch {
					// Handle error here
				}
			}
		}
	}

	deinit {
		uploadTask?.cancel()
		uploadTask = nil
	}

	static func shared() -> SyncableManagerProtocol {
		return SyncManager()
	}

	/// Saves `[Step]` to `SwiftData`
	func saveSteps(steps: [Step]) async throws(SyncableError) {
		for step in steps {
			guard uniqueValues.insert(step).inserted else { continue }
			try await saveStep(step: step)
			newValuePublisher.send(step)
		}
	}

	/// Saves `Step` to `SwiftData`
	/// Converts `Step` to `StepRecord` and pass it to `appendRecord`
	private func saveStep(step: Step) async throws(SyncableError) {
		steps.append(step)
		let dbStep = StepRecord(step: step)
		try await appendRecord(record: dbStep)
	}

	/// Saves `StepRecord` to `SwiftData`
	private func appendRecord(record: StepRecord) async throws(SyncableError) {
		modelContext.insert(record)
		do {
			try modelContext.save()
		} catch {
			throw .saveFailed(error.localizedDescription)
		}
	}

	/// Fetches all `StepRecords` currently not synced
	private func fetchNoneSyncedItems() async throws(SyncableError) -> [StepRecord] {
		let fetchDescriptor = FetchDescriptor<StepRecord>()
		do {
			let items = try modelContext.fetch(fetchDescriptor)
			/// All `StepRecords` with  `isSynced` as `false` are not synced
			return items.filter { $0.isSynced == false }
		} catch {
			throw .fetchFailed(error.localizedDescription)
		}
	}

	/// Removes `StepRecord` from `SwiftData` based on `id`
	/// TODO: Not implemented, but a good idea to prune the local `DB` of `synced` items based on `Date`
	private func removeItem(with id: UUID) async throws(SyncableError) {
		let fetchDescriptor = FetchDescriptor<StepRecord>()
		do {
			let items: [StepRecord] = try modelContext.fetch(fetchDescriptor)
			guard let itemToDelete = items.first(where: { $0.id == id }) else {
				throw SyncableError.recordNotFound
			}
			modelContext.delete(itemToDelete)
			try modelContext.save()
		} catch {
			throw .deletionFailed(error.localizedDescription)
		}
	}

	/// Uploads None Synced Items to `API`, if successful will change `isSynced` on `StepRecord` to `true`
	/// TODO: Due to 500 API error, this does not upload, just sets `isSynced` to `true` every time it's called
	func uploadNoneSyncedItem() async throws(SyncableError) {
		let items = try await fetchNoneSyncedItems()

		let uploadableData = items.map { $0.step }.mapStepsToStepData(username: "user1@test.com")

		for uploadableItem in uploadableData {
			do {
				try await self.uploader.uploadStepData(stepData: uploadableItem)
			} catch {
				throw .uploadFailed(error.localizedDescription)
			}
		}

		for item in items {
			item.isSynced = true
		}
	}
}

