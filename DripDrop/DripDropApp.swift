//
//  DripDropApp.swift
//  DripDrop
//
//  Created by Chris McElroy on 12/15/22.
//

import SwiftUI

@main
struct DripDropApp: App {
	init() {
		UserDefaults.standard.register(defaults: [
			Key.dayStart.rawValue: 360,
			Key.dayEnd.rawValue: 1320,
			Key.defaultSize.rawValue: 12
		])
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
