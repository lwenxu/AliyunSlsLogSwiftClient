//
//  File.swift
//  
//
//  Created by lwen on 2024/11/3.
//

import Foundation
import CryptoKit


public struct DigestUtils {
    
    @available(macOS 10.15, *)
    public static func genSignature(sk:String,method:String,headers:[String:String],uri:String,params:[String:String]) -> String {
        
    
        
        let content = [
            method,
            headers["Content-MD5"] ?? "",
            headers["Content-Type"] ?? "",
            headers["Date"] ?? "",
            buildXHeaders(headers: headers),
            HttpUtils.buildUri(uri, params)
        ].joined(separator: "\n")
        
        return doSignature(content, sk)
    }
    
    @available(macOS 10.15, *)
    private static func doSignature(_ message: String,_ key0:String) -> String {
        let key = Data(key0.utf8)
        let messageData = Data(message.utf8)
        let signature = HMAC<Insecure.SHA1>.authenticationCode(for: messageData, using: SymmetricKey(data: key))
        return Data(signature).base64EncodedString()
    }
    
    private static func buildXHeaders(headers:[String:String]) -> String {
        return headers.filter{ (k,v) in
            k.contains("x-log-")
        }.sorted(by: {$0.key < $1.key} ).map { "\($0.key):\($0.value)" }.joined(separator: "\n")
    }
    
}
