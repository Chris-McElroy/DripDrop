//
//  StorageHelper.swift
//  DripDrop
//
//  Created by Chris McElroy on 12/15/22.
//

import Foundation

class Storage {	
	static func dictionary(_ key: Key) -> [String: Any]? {
		UserDefaults.standard.dictionary(forKey: key.rawValue)
	}
	
	static func array(_ key: Key) -> [Any]? {
		UserDefaults.standard.array(forKey: key.rawValue)
	}
	
	static func int(_ key: Key) -> Int {
		UserDefaults.standard.integer(forKey: key.rawValue)
	}
	
	static func double(_ key: Key) -> Double {
		UserDefaults.standard.double(forKey: key.rawValue)
	}
	
	static func string(_ key: Key) -> String? {
		UserDefaults.standard.string(forKey: key.rawValue)
	}
	
	static func set(_ value: Any?, for key: Key) {
		UserDefaults.standard.setValue(value, forKey: key.rawValue)
	}
}

enum Key: String {
	case logHistory = "logHistory"
	case goalHistory = "goalHistory"
	case defaultSize = "defaultSize"
	case dayStart = "dayStart"
	case dayEnd = "dayEnd"
}
