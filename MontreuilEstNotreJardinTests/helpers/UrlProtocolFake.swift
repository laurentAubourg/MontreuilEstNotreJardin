//
//  URLProtocolFake.swift
//  MontreuilEstNotreJardin
//
//  Created byLaurent Aubourg on 08/02/2022.
//

import Foundation

// MARK: - URLProtocol manages the loading of the data we want to return

class URLProtocolFake: URLProtocol {
    static var fakeURLs = [URL?: (data: Data?, response: HTTPURLResponse?, error: Error?)]()

    //  Determines if the protocol subclass can handle the specified request
    override class func canInit(with request: URLRequest) -> Bool { true }

   // Returns a canonical version of the specified query
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request }

    // Starts the protocol-specific loading of the request
    override func startLoading() {
        if let url = request.url {
            if let (data, response, error) = URLProtocolFake.fakeURLs[url] {
              if let responseStrong =  response{
                    client?.urlProtocol(self, didReceive: responseStrong, cacheStoragePolicy: .notAllowed)
               }
                if let dataStrong = data {
                    client?.urlProtocol(self, didLoad: dataStrong)
                }
                if let errorStrong = error {
                    client?.urlProtocol(self, didFailWithError: errorStrong)
                }
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    // Arrête le chargement, spécifique au protocol, de la demande
    override func stopLoading() { }
}
