// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CryptoKit

@available(macOS 10.15, *)
public struct AliyunSlsLogSwiftClient{
    
    
    let API_VERSION = "0.6.0"
    let SIGN_METHOD = "hmac-sha1"
    let CONTENT_TYPE_JSON = "application/json"
    
    
    let HTTP_GET = "GET"
    let HTTP_POST = "POST"
    
    public var session = URLSession.shared
    
    private var ak:String
    private var sk:String
    private var endpoint:String
    
    public init(ak: String, sk: String, endpoint: String) {
        self.ak = ak
        self.sk = sk
        self.endpoint = endpoint
    }
    
    
    public func getLogs(_ request : GetLogRequest) async throws -> [[String: Any]] {
        let uri = "/logstores/\(request.logStore)"
        let urlParams:[String:String]  = [
            "project": request.projName,
            "from": String(request.startSecond),
            "to": String(request.endSecond),
            "type":"log"
        ]
        return try await doRequest(projName:request.projName,httpMethod:HTTP_GET,uri:uri,urlParams:urlParams,body:nil)
    }
    
    public func doRequest(projName:String,httpMethod:String,uri:String,urlParams:[String:String],body:Data?) async throws -> [[String: Any]] {
        var header = buildCommonHeader(projName)
        if let bodyData = body {
            header["Content-MD5"] = bodyData.md5()
        }
        let contentSize = body?.count ?? 0
        if contentSize > 0 {
            header["Content-Length"] = String(contentSize)
        }
        
        let sign = DigestUtils.genSignature(sk: self.sk, method: httpMethod, headers: header, uri: uri, params: urlParams)
        header["Authorization"] = "LOG \(self.ak):\(sign)"
        
        
        var httpRequest = URLRequest(url: URL(string: HttpUtils.buildUrl(self.endpoint,uri,urlParams))!)
        header.forEach{ (k,v) in
            httpRequest.addValue(v, forHTTPHeaderField: k)
        }
        httpRequest.httpMethod = HTTP_GET
                
        let (data, response) = try await session.data(for: httpRequest)
        if let r = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return r
        }else{
            print("请求失败")
            return [[:]]
        }
//        
//        { data, _, error in
//            
//            if let error = error {
//                print("Error fetching posts: \(error.localizedDescription)")
//                return
//            }
//            
//            if let data = data {
//                do {
//                    
//                } catch {
//                    print("Error decoding posts: \(error.localizedDescription)")
//                }
//            }
//        }
//        
//        task.resume()
        
        
    }
    
    func toJsonString(_ data:Any) -> String{
        return String(data:try! JSONSerialization.data(withJSONObject: data,options: [.prettyPrinted]),encoding: .utf8)!
    }
    
    
    public func buildCommonHeader(_ projName:String) -> [String:String] {
        return [
            "x-log-signaturemethod": SIGN_METHOD,
            "x-log-apiversion": API_VERSION,
            "x-log-bodyrawsize": "0",
            "Date": getDateString(),
            "Host": "\(projName).\(self.endpoint)"
        ]
    }
    
    public func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 设置时区为 GMT
        
        return dateFormatter.string(from: Date())
    }
    
    
}


@available(macOS 10.15, *)
private extension Data {
    func md5() -> String {
        let hash = Insecure.MD5.hash(data: self)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
