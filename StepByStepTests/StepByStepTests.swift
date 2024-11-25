//
//  StepByStepTests.swift
//  StepByStepTests
//
//  Created by Stefan Progovac on 11/24/24.
//

import Testing
import Foundation

@testable import StepByStep

/// Sample Testing suite
/// - TODO Add more test cases
@Suite
class TestDecodingModels {
	// 🚧
	deinit {
		// instance level deinit code
		URLProtocol.unregisterClass(MockURLProtocol.self)
	}

	// 🚧
	init() {
		// instance level init code
		URLProtocol.registerClass(MockURLProtocol.self)
	}

	/// Loads mock JSON
	private func loadMockStepsData() async throws -> [StepData] {
		let baseURL = AppAPIEnvironment.development.baseURL
		MockURLProtocol.mockResponses[baseURL] = expectedJSON.data(using: .utf8)

		let (data, _) = try await URLSession.shared.data(for: URLRequest(url: baseURL))

		let steps = try JSONDecoder().decode([StepData].self, from: data)

		return steps
	}

	/// Initializes `StepFetcher` with mock JSON
	/// Note it will throw an error due to no User Object found
	/// TODO create test case where `StepFetcher` is injected with mock User Object/token
	private func configureStepsFetcherAndFetch() async throws -> [StepData] {
		let baseURL = AppAPIEnvironment.development.baseURL
		MockURLProtocol.mockResponses[baseURL] = expectedJSON.data(using: .utf8)

		let fetcher = StepsFetcher()

		return try await fetcher.fetchSteps()
	}

	/// Tests if mock JSON is properly decoded
	@Test
	func decodingStepHistory() async throws {

		let steps = try #require(await loadMockStepsData())
		#expect(steps.count == 100)

	}

	/// Tests that `StepsFetcher` throws an `error`
	@Test func stepsFetcherUserNotLoggedInError() async throws {
		await #expect(throws: StepsFetchError.userNotLoggedIn) {
			try await configureStepsFetcherAndFetch()
		}
	}
}

/// Mock JSON string
/// Pulled from LIVE `API` response
/// TODO format into `pretty print` and pull to `.json` file, include other mocks
fileprivate let expectedJSON = "[{\"id\":75,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:58:36.979Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:58:37.028Z\",\"updated_at\":\"2023-01-31T07:58:37.028Z\",\"steps_total_by_day\":5060},{\"id\":76,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:58:46.970Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:58:47.020Z\",\"updated_at\":\"2023-01-31T07:58:47.020Z\",\"steps_total_by_day\":5060},{\"id\":77,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:58:56.971Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:58:57.016Z\",\"updated_at\":\"2023-01-31T07:58:57.016Z\",\"steps_total_by_day\":5060},{\"id\":78,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:59:05.702Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:59:05.756Z\",\"updated_at\":\"2023-01-31T07:59:05.756Z\",\"steps_total_by_day\":5060},{\"id\":79,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:59:15.428Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:59:15.475Z\",\"updated_at\":\"2023-01-31T07:59:15.475Z\",\"steps_total_by_day\":5060},{\"id\":80,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:59:34.860Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:59:34.905Z\",\"updated_at\":\"2023-01-31T07:59:34.905Z\",\"steps_total_by_day\":5060},{\"id\":10,\"username\":\"qtrang\",\"steps_date\":\"2023-01-01\",\"steps_datetime\":\"2023-01-01T14:30:00.000Z\",\"steps_count\":1977,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T19:58:25.272Z\",\"updated_at\":\"2023-01-30T19:58:25.272Z\",\"steps_total_by_day\":7890},{\"id\":11,\"username\":\"qtrang\",\"steps_date\":\"2023-01-02\",\"steps_datetime\":\"2023-01-02T14:30:00.000Z\",\"steps_count\":9144,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T19:58:59.244Z\",\"updated_at\":\"2023-01-30T19:58:59.244Z\",\"steps_total_by_day\":959},{\"id\":12,\"username\":\"qtrang\",\"steps_date\":\"2023-01-03\",\"steps_datetime\":\"2023-01-03T14:30:00.000Z\",\"steps_count\":3074,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T19:59:46.603Z\",\"updated_at\":\"2023-01-30T19:59:46.603Z\",\"steps_total_by_day\":5676},{\"id\":13,\"username\":\"qtrang\",\"steps_date\":\"2023-01-04\",\"steps_datetime\":\"2023-01-04T14:30:00.000Z\",\"steps_count\":8432,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T19:59:54.460Z\",\"updated_at\":\"2023-01-30T19:59:54.460Z\",\"steps_total_by_day\":187},{\"id\":14,\"username\":\"qtrang\",\"steps_date\":\"2023-01-05\",\"steps_datetime\":\"2023-01-05T14:30:00.000Z\",\"steps_count\":8703,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:00:01.791Z\",\"updated_at\":\"2023-01-30T20:00:01.791Z\",\"steps_total_by_day\":706},{\"id\":15,\"username\":\"qtrang\",\"steps_date\":\"2023-01-06\",\"steps_datetime\":\"2023-01-06T14:30:00.000Z\",\"steps_count\":5473,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:00:11.905Z\",\"updated_at\":\"2023-01-30T20:00:11.905Z\",\"steps_total_by_day\":6180},{\"id\":16,\"username\":\"qtrang\",\"steps_date\":\"2023-01-07\",\"steps_datetime\":\"2023-01-07T14:30:00.000Z\",\"steps_count\":7299,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:00:15.936Z\",\"updated_at\":\"2023-01-30T20:00:15.936Z\",\"steps_total_by_day\":6502},{\"id\":17,\"username\":\"qtrang\",\"steps_date\":\"2023-01-08\",\"steps_datetime\":\"2023-01-08T14:30:00.000Z\",\"steps_count\":6945,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:00:44.538Z\",\"updated_at\":\"2023-01-30T20:00:44.538Z\",\"steps_total_by_day\":6497},{\"id\":18,\"username\":\"qtrang\",\"steps_date\":\"2023-01-09\",\"steps_datetime\":\"2023-01-09T14:30:00.000Z\",\"steps_count\":3415,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:00:52.006Z\",\"updated_at\":\"2023-01-30T20:00:52.006Z\",\"steps_total_by_day\":8240},{\"id\":19,\"username\":\"qtrang\",\"steps_date\":\"2023-01-10\",\"steps_datetime\":\"2023-01-10T14:30:00.000Z\",\"steps_count\":4469,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:01:03.607Z\",\"updated_at\":\"2023-01-30T20:01:03.607Z\",\"steps_total_by_day\":6675},{\"id\":20,\"username\":\"qtrang\",\"steps_date\":\"2023-01-11\",\"steps_datetime\":\"2023-01-11T14:30:00.000Z\",\"steps_count\":908,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:01:24.830Z\",\"updated_at\":\"2023-01-30T20:01:24.830Z\",\"steps_total_by_day\":2869},{\"id\":21,\"username\":\"qtrang\",\"steps_date\":\"2023-01-11\",\"steps_datetime\":\"2023-01-11T14:30:00.000Z\",\"steps_count\":6973,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:01:36.302Z\",\"updated_at\":\"2023-01-30T20:01:36.302Z\",\"steps_total_by_day\":4345},{\"id\":22,\"username\":\"qtrang\",\"steps_date\":\"2023-01-12\",\"steps_datetime\":\"2023-01-12T14:30:00.000Z\",\"steps_count\":6955,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:01:43.736Z\",\"updated_at\":\"2023-01-30T20:01:43.736Z\",\"steps_total_by_day\":4249},{\"id\":23,\"username\":\"qtrang\",\"steps_date\":\"2023-01-13\",\"steps_datetime\":\"2023-01-13T14:30:00.000Z\",\"steps_count\":8597,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:01:52.694Z\",\"updated_at\":\"2023-01-30T20:01:52.694Z\",\"steps_total_by_day\":3998},{\"id\":24,\"username\":\"qtrang\",\"steps_date\":\"2023-01-14\",\"steps_datetime\":\"2023-01-14T14:30:00.000Z\",\"steps_count\":3561,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:01.398Z\",\"updated_at\":\"2023-01-30T20:02:01.398Z\",\"steps_total_by_day\":5474},{\"id\":25,\"username\":\"qtrang\",\"steps_date\":\"2023-01-15\",\"steps_datetime\":\"2023-01-15T14:30:00.000Z\",\"steps_count\":1040,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:07.159Z\",\"updated_at\":\"2023-01-30T20:02:07.159Z\",\"steps_total_by_day\":7050},{\"id\":26,\"username\":\"qtrang\",\"steps_date\":\"2023-01-16\",\"steps_datetime\":\"2023-01-16T14:30:00.000Z\",\"steps_count\":9511,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:12.159Z\",\"updated_at\":\"2023-01-30T20:02:12.159Z\",\"steps_total_by_day\":6049},{\"id\":27,\"username\":\"qtrang\",\"steps_date\":\"2023-01-17\",\"steps_datetime\":\"2023-01-17T14:30:00.000Z\",\"steps_count\":7407,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:17.889Z\",\"updated_at\":\"2023-01-30T20:02:17.889Z\",\"steps_total_by_day\":5131},{\"id\":28,\"username\":\"qtrang\",\"steps_date\":\"2023-01-18\",\"steps_datetime\":\"2023-01-18T14:30:00.000Z\",\"steps_count\":4931,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:24.281Z\",\"updated_at\":\"2023-01-30T20:02:24.281Z\",\"steps_total_by_day\":6704},{\"id\":29,\"username\":\"qtrang\",\"steps_date\":\"2023-01-19\",\"steps_datetime\":\"2023-01-19T14:30:00.000Z\",\"steps_count\":7949,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:30.374Z\",\"updated_at\":\"2023-01-30T20:02:30.374Z\",\"steps_total_by_day\":9217},{\"id\":30,\"username\":\"qtrang\",\"steps_date\":\"2023-01-20\",\"steps_datetime\":\"2023-01-20T14:30:00.000Z\",\"steps_count\":7911,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:36.985Z\",\"updated_at\":\"2023-01-30T20:02:36.985Z\",\"steps_total_by_day\":3980},{\"id\":31,\"username\":\"qtrang\",\"steps_date\":\"2023-01-21\",\"steps_datetime\":\"2023-01-21T14:30:00.000Z\",\"steps_count\":1316,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:42.506Z\",\"updated_at\":\"2023-01-30T20:02:42.506Z\",\"steps_total_by_day\":286},{\"id\":32,\"username\":\"qtrang\",\"steps_date\":\"2023-01-22\",\"steps_datetime\":\"2023-01-22T14:30:00.000Z\",\"steps_count\":802,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:48.297Z\",\"updated_at\":\"2023-01-30T20:02:48.297Z\",\"steps_total_by_day\":3268},{\"id\":33,\"username\":\"qtrang\",\"steps_date\":\"2023-01-23\",\"steps_datetime\":\"2023-01-23T14:30:00.000Z\",\"steps_count\":1729,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:53.895Z\",\"updated_at\":\"2023-01-30T20:02:53.895Z\",\"steps_total_by_day\":8476},{\"id\":34,\"username\":\"qtrang\",\"steps_date\":\"2023-01-24\",\"steps_datetime\":\"2023-01-24T14:30:00.000Z\",\"steps_count\":8889,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:02:59.027Z\",\"updated_at\":\"2023-01-30T20:02:59.027Z\",\"steps_total_by_day\":506},{\"id\":35,\"username\":\"qtrang\",\"steps_date\":\"2023-01-25\",\"steps_datetime\":\"2023-01-25T14:30:00.000Z\",\"steps_count\":8925,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:03:03.776Z\",\"updated_at\":\"2023-01-30T20:03:03.776Z\",\"steps_total_by_day\":4146},{\"id\":36,\"username\":\"qtrang\",\"steps_date\":\"2023-01-26\",\"steps_datetime\":\"2023-01-26T14:30:00.000Z\",\"steps_count\":3117,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:03:09.529Z\",\"updated_at\":\"2023-01-30T20:03:09.529Z\",\"steps_total_by_day\":931},{\"id\":37,\"username\":\"qtrang\",\"steps_date\":\"2023-01-27\",\"steps_datetime\":\"2023-01-27T14:30:00.000Z\",\"steps_count\":9852,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:03:19.571Z\",\"updated_at\":\"2023-01-30T20:03:19.571Z\",\"steps_total_by_day\":2634},{\"id\":38,\"username\":\"qtrang\",\"steps_date\":\"2023-01-28\",\"steps_datetime\":\"2023-01-28T14:30:00.000Z\",\"steps_count\":7632,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:03:26.536Z\",\"updated_at\":\"2023-01-30T20:03:26.536Z\",\"steps_total_by_day\":2829},{\"id\":39,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T14:30:00.000Z\",\"steps_count\":8772,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-30T20:03:38.740Z\",\"updated_at\":\"2023-01-30T20:03:38.740Z\",\"steps_total_by_day\":8313},{\"id\":40,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T02:27:57.000Z\",\"steps_count\":9461,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:32:28.424Z\",\"updated_at\":\"2023-01-31T02:32:28.424Z\",\"steps_total_by_day\":8465},{\"id\":41,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T01:27:57.000Z\",\"steps_count\":8426,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:32:41.090Z\",\"updated_at\":\"2023-01-31T02:32:41.090Z\",\"steps_total_by_day\":3416},{\"id\":42,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T00:27:57.000Z\",\"steps_count\":5489,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:32:50.470Z\",\"updated_at\":\"2023-01-31T02:32:50.470Z\",\"steps_total_by_day\":4709},{\"id\":43,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T23:27:57.000Z\",\"steps_count\":6032,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:32:58.665Z\",\"updated_at\":\"2023-01-31T02:32:58.665Z\",\"steps_total_by_day\":9145},{\"id\":44,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T22:27:57.000Z\",\"steps_count\":3598,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:33:10.271Z\",\"updated_at\":\"2023-01-31T02:33:10.271Z\",\"steps_total_by_day\":1046},{\"id\":45,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T21:27:57.000Z\",\"steps_count\":6301,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:33:15.309Z\",\"updated_at\":\"2023-01-31T02:33:15.309Z\",\"steps_total_by_day\":6235},{\"id\":46,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T20:27:57.000Z\",\"steps_count\":263,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:33:22.630Z\",\"updated_at\":\"2023-01-31T02:33:22.630Z\",\"steps_total_by_day\":3489},{\"id\":47,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T19:27:57.000Z\",\"steps_count\":7772,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:33:28.514Z\",\"updated_at\":\"2023-01-31T02:33:28.514Z\",\"steps_total_by_day\":7131},{\"id\":48,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T18:27:57.000Z\",\"steps_count\":837,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:33:37.830Z\",\"updated_at\":\"2023-01-31T02:33:37.830Z\",\"steps_total_by_day\":7873},{\"id\":49,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T17:27:57.000Z\",\"steps_count\":841,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:33:47.837Z\",\"updated_at\":\"2023-01-31T02:33:47.837Z\",\"steps_total_by_day\":5395},{\"id\":50,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T17:23:57.000Z\",\"steps_count\":4850,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:34:16.130Z\",\"updated_at\":\"2023-01-31T02:34:16.130Z\",\"steps_total_by_day\":5671},{\"id\":51,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T16:31:57.000Z\",\"steps_count\":7643,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:34:24.950Z\",\"updated_at\":\"2023-01-31T02:34:24.950Z\",\"steps_total_by_day\":2767},{\"id\":52,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-30T15:03:57.000Z\",\"steps_count\":1261,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:34:49.540Z\",\"updated_at\":\"2023-01-31T02:34:49.540Z\",\"steps_total_by_day\":8324},{\"id\":53,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T02:43:53.000Z\",\"steps_count\":1027,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:44:43.754Z\",\"updated_at\":\"2023-01-31T02:44:43.754Z\",\"steps_total_by_day\":3333},{\"id\":55,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T02:45:00.000Z\",\"steps_count\":2178,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T02:45:09.967Z\",\"updated_at\":\"2023-01-31T02:45:09.967Z\",\"steps_total_by_day\":4664},{\"id\":56,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:40:36.227Z\",\"steps_count\":4820,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:40:36.291Z\",\"updated_at\":\"2023-01-31T06:40:36.291Z\",\"steps_total_by_day\":4820},{\"id\":57,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:40:36.226Z\",\"steps_count\":4820,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:40:36.320Z\",\"updated_at\":\"2023-01-31T06:40:36.320Z\",\"steps_total_by_day\":4820},{\"id\":58,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:41:21.259Z\",\"steps_count\":4820,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:41:21.302Z\",\"updated_at\":\"2023-01-31T06:41:21.302Z\",\"steps_total_by_day\":4820},{\"id\":59,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:41:30.965Z\",\"steps_count\":4820,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:41:31.001Z\",\"updated_at\":\"2023-01-31T06:41:31.001Z\",\"steps_total_by_day\":4820},{\"id\":60,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:41:40.959Z\",\"steps_count\":4820,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:41:40.997Z\",\"updated_at\":\"2023-01-31T06:41:40.997Z\",\"steps_total_by_day\":4820},{\"id\":61,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:42:27.509Z\",\"steps_count\":5040,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:42:27.564Z\",\"updated_at\":\"2023-01-31T06:42:27.564Z\",\"steps_total_by_day\":5040},{\"id\":62,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:42:30.961Z\",\"steps_count\":5040,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:42:31.001Z\",\"updated_at\":\"2023-01-31T06:42:31.001Z\",\"steps_total_by_day\":5040},{\"id\":63,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:42:40.961Z\",\"steps_count\":5040,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:42:40.995Z\",\"updated_at\":\"2023-01-31T06:42:40.995Z\",\"steps_total_by_day\":5040},{\"id\":64,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:44:33.496Z\",\"steps_count\":5040,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:44:33.591Z\",\"updated_at\":\"2023-01-31T06:44:33.591Z\",\"steps_total_by_day\":5040},{\"id\":65,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:44:43.100Z\",\"steps_count\":5040,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:44:43.182Z\",\"updated_at\":\"2023-01-31T06:44:43.182Z\",\"steps_total_by_day\":5040},{\"id\":66,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:46:49.592Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:46:49.670Z\",\"updated_at\":\"2023-01-31T06:46:49.670Z\",\"steps_total_by_day\":5060},{\"id\":67,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:46:59.209Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:46:59.290Z\",\"updated_at\":\"2023-01-31T06:46:59.290Z\",\"steps_total_by_day\":5060},{\"id\":68,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:48:59.661Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:48:59.788Z\",\"updated_at\":\"2023-01-31T06:48:59.788Z\",\"steps_total_by_day\":5060},{\"id\":69,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:51:16.689Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:51:16.871Z\",\"updated_at\":\"2023-01-31T06:51:16.871Z\",\"steps_total_by_day\":5060},{\"id\":70,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T06:51:16.874Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T06:51:16.954Z\",\"updated_at\":\"2023-01-31T06:51:16.954Z\",\"steps_total_by_day\":5060},{\"id\":71,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:57:55.849Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:57:55.917Z\",\"updated_at\":\"2023-01-31T07:57:55.917Z\",\"steps_total_by_day\":5060},{\"id\":72,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:58:05.355Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:58:05.400Z\",\"updated_at\":\"2023-01-31T07:58:05.400Z\",\"steps_total_by_day\":5060},{\"id\":73,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:58:17.291Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:58:17.338Z\",\"updated_at\":\"2023-01-31T07:58:17.338Z\",\"steps_total_by_day\":5060},{\"id\":74,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:58:26.979Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:58:27.023Z\",\"updated_at\":\"2023-01-31T07:58:27.023Z\",\"steps_total_by_day\":5060},{\"id\":81,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:59:44.524Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:59:44.574Z\",\"updated_at\":\"2023-01-31T07:59:44.574Z\",\"steps_total_by_day\":5060},{\"id\":82,\"username\":\"qtrang\",\"steps_date\":\"2023-01-30\",\"steps_datetime\":\"2023-01-31T07:59:54.522Z\",\"steps_count\":5060,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T07:59:54.570Z\",\"updated_at\":\"2023-01-31T07:59:54.570Z\",\"steps_total_by_day\":5060},{\"id\":83,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:00:04.501Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:00:04.569Z\",\"updated_at\":\"2023-01-31T08:00:04.569Z\",\"steps_total_by_day\":0},{\"id\":84,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:00:14.488Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:00:14.572Z\",\"updated_at\":\"2023-01-31T08:00:14.572Z\",\"steps_total_by_day\":0},{\"id\":85,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:00:24.482Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:00:24.573Z\",\"updated_at\":\"2023-01-31T08:00:24.573Z\",\"steps_total_by_day\":0},{\"id\":86,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:00:32.075Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:00:32.165Z\",\"updated_at\":\"2023-01-31T08:00:32.165Z\",\"steps_total_by_day\":0},{\"id\":87,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:00:41.717Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:00:41.810Z\",\"updated_at\":\"2023-01-31T08:00:41.810Z\",\"steps_total_by_day\":0},{\"id\":88,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:00:51.712Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:00:51.802Z\",\"updated_at\":\"2023-01-31T08:00:51.802Z\",\"steps_total_by_day\":0},{\"id\":89,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:01:01.715Z\",\"steps_count\":0,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:01:01.807Z\",\"updated_at\":\"2023-01-31T08:01:01.807Z\",\"steps_total_by_day\":0},{\"id\":90,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:01:35.533Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:01:35.683Z\",\"updated_at\":\"2023-01-31T08:01:35.683Z\",\"steps_total_by_day\":5},{\"id\":91,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:01:44.993Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:01:45.088Z\",\"updated_at\":\"2023-01-31T08:01:45.088Z\",\"steps_total_by_day\":5},{\"id\":92,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:01:54.991Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:01:55.089Z\",\"updated_at\":\"2023-01-31T08:01:55.089Z\",\"steps_total_by_day\":5},{\"id\":93,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:02:04.992Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:02:05.086Z\",\"updated_at\":\"2023-01-31T08:02:05.086Z\",\"steps_total_by_day\":5},{\"id\":94,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:02:13.277Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:02:13.373Z\",\"updated_at\":\"2023-01-31T08:02:13.373Z\",\"steps_total_by_day\":5},{\"id\":95,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:02:22.970Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:02:23.064Z\",\"updated_at\":\"2023-01-31T08:02:23.064Z\",\"steps_total_by_day\":5},{\"id\":96,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:02:32.961Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:02:33.056Z\",\"updated_at\":\"2023-01-31T08:02:33.056Z\",\"steps_total_by_day\":5},{\"id\":97,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:02:42.959Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:02:43.053Z\",\"updated_at\":\"2023-01-31T08:02:43.053Z\",\"steps_total_by_day\":5},{\"id\":98,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:02:52.959Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:02:53.057Z\",\"updated_at\":\"2023-01-31T08:02:53.057Z\",\"steps_total_by_day\":5},{\"id\":99,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:03:02.960Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:03:03.055Z\",\"updated_at\":\"2023-01-31T08:03:03.055Z\",\"steps_total_by_day\":5},{\"id\":100,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:03:12.960Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:03:13.053Z\",\"updated_at\":\"2023-01-31T08:03:13.053Z\",\"steps_total_by_day\":5},{\"id\":101,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:03:22.959Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:03:23.054Z\",\"updated_at\":\"2023-01-31T08:03:23.054Z\",\"steps_total_by_day\":5},{\"id\":102,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:03:32.959Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:03:33.055Z\",\"updated_at\":\"2023-01-31T08:03:33.055Z\",\"steps_total_by_day\":5},{\"id\":103,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:03:42.966Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:03:43.064Z\",\"updated_at\":\"2023-01-31T08:03:43.064Z\",\"steps_total_by_day\":5},{\"id\":104,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:03:52.962Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:03:53.061Z\",\"updated_at\":\"2023-01-31T08:03:53.061Z\",\"steps_total_by_day\":5},{\"id\":105,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:04:02.958Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:04:03.055Z\",\"updated_at\":\"2023-01-31T08:04:03.055Z\",\"steps_total_by_day\":5},{\"id\":106,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:04:12.960Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:04:13.055Z\",\"updated_at\":\"2023-01-31T08:04:13.055Z\",\"steps_total_by_day\":5},{\"id\":107,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:04:33.799Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:04:33.900Z\",\"updated_at\":\"2023-01-31T08:04:33.900Z\",\"steps_total_by_day\":5},{\"id\":108,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:04:43.454Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:04:43.558Z\",\"updated_at\":\"2023-01-31T08:04:43.558Z\",\"steps_total_by_day\":5},{\"id\":109,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:04:53.456Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:04:53.553Z\",\"updated_at\":\"2023-01-31T08:04:53.553Z\",\"steps_total_by_day\":5},{\"id\":110,\"username\":\"qtrang\",\"steps_date\":\"2023-01-31\",\"steps_datetime\":\"2023-01-31T08:05:03.452Z\",\"steps_count\":5,\"steps_total\":null,\"created_datetime\":null,\"created_at\":\"2023-01-31T08:05:03.543Z\",\"updated_at\":\"2023-01-31T08:05:03.543Z\",\"steps_total_by_day\":5}]"
