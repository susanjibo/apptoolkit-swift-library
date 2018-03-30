//
//  ListenCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Language
/// :nodoc: Language codes for Jibo. Only English is supported
public enum LangCode: String {
	/// English
	case en 	= "en"
	/// English
	case enUS 	= "en-US"
}

public typealias Timeout = UInt

class ListenCommand: Command {
	static var maxSpeechLength: UInt = UInt(15).secondToMicroSeconds()

	var maxSpeechTimeout: Timeout?
	var maxNoSpeechTimeout: Timeout?
	var languageCode: LangCode?
	
    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .listen
    }
    
    convenience init?(maxSpeechTimeOut: Timeout = maxSpeechLength,
                             maxNoSpeechTimeout: Timeout,
                             languageCode: LangCode = .enUS) {
		self.init(map: Map(mappingType: .fromJSON, JSON: [:]))
		
		self.maxSpeechTimeout = maxSpeechTimeOut
		self.maxNoSpeechTimeout = maxNoSpeechTimeout
		self.languageCode = languageCode
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		maxSpeechTimeout	<- map["MaxSpeechTimeout"]
		maxNoSpeechTimeout	<- map["MaxNoSpeechTimeout"]
		languageCode		<- map["LanguageCode"]
	}
}
