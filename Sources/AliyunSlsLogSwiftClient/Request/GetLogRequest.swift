//
//  File.swift
//
//
//  Created by lwen on 2024/11/3.
//

import Foundation

public struct GetLogRequest : Codable {

    public var projName:String
    public var logStore:String
    public var startSecond:Int
    public var endSecond:Int
    public var query:String
    public var reverse:Bool = true

}
