//
//  File 2.swift
//  
//
//  Created by lwen on 2024/11/3.
//

import Foundation

public struct HttpUtils{
    
    public static func buildQueryString(_ params:[String:String]) -> String {
        return params.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
    
    public static func buildUri(_ path:String, _ params:[String:String] ) -> String {
        return "\(path)?\(buildQueryString(params))"
    }
    
    public static func buildUrl(_ host:String,_ path:String, _ params:[String:String] ) -> String {
        return "http://\(host)\(path)?\(buildQueryString(params))"
    }
    
}
