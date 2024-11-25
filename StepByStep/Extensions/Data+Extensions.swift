//
//  Data+Extensions.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

extension Data {
	/// Just returns a `String` in `pretty print` from the `Data` whenever the `Data` represents a `JSON`
	var prettyPrintedJSONString: NSString? {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
			  let data = try? JSONSerialization.data(withJSONObject: jsonObject,
													 options: [.prettyPrinted]),
			  let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
				return nil
			  }

		return prettyJSON
	}
}
