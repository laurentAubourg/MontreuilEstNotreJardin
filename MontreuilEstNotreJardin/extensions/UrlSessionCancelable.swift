//
//  serviceExtension.swift
//  baluchon
//
//  Created by laurent aubourg on 08/09/2021.
//
import Foundation
protocol UrlSessionCancelable{
    var lastUrl:URL { get set}
    var session:URLSession{ get set}
}

extension UrlSessionCancelable{
    
    // MARK:  - remove task from the session actualy running and with an url  equal to the url parameter
    
    func cancel(_ url: URL)-> Bool {
        var response:Bool = false
        session.getAllTasks { tasks in
            if( tasks.filter { $0.state == .running }.count > 0){
                tasks.filter { $0.state == .running }
                .filter { $0.originalRequest?.url == url }.first?
                .cancel()
                response =  true
            }
        }
        return  response
    }
}
