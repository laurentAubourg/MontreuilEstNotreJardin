//
//
//  MontreuilEstNotreJardin
//  DataSetServiceTestCase
//
//  Created by laurent aubourg on 08/02/2022
//

import XCTest
@testable import MontreuilEstNotreJardin

class DataSetServiceTestCase: XCTestCase {
    
    // MARK: - Properties

    private let sessionConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolFake.self]
        return sessionConfiguration
    }()
   
    
    //MARK: I getFacets  test invalidData
    
    func  testDataIsIncorrect_WhenGetFacet_ThenReceiveUndecodableData(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlFacet: (FakeResponseData.incorrectData, FakeResponseData.responseOK, nil)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...change threat")
        sut.getFacets() { result in
            
            guard case .failure(let error) = result else {
                XCTFail("Test failed: \(#function)")
                return
            }
            XCTAssertTrue(error == .undecodableData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    //MARK: II. getFacets  test invalidResponse
    
    func  testInvalidResponse_WhenGetFacet_ThenReceiveInvalidResponse(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlFacet: (FakeResponseData.facetCorrectData, FakeResponseData.responseKO, nil)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...")
        sut.getFacets{ result in
            
            guard case .failure(let error) = result else {
                XCTFail("Test failed: \(#function)")
                return
            }
            XCTAssertTrue(error == .invalidResponse)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    //MARK: III. getFacets test .nodata
    
    func  testNoData_WhenFacetDataIsNull_ThenReceiveNoData(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlFacet: (nil, FakeResponseData.responseOK, FakeResponseData.error)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...")
        sut.getFacets { result in
            
            guard case .failure(let error) = result else {
                XCTFail("Test failed: \(#function)")
                return
            }
            XCTAssertTrue(error == .noData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    //MARK: IV  getFacets test data and response are OK
    
    func  testData_WhenFacetDataIsCorrect_ThenReceiveData(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlFacet: (FakeResponseData.facetCorrectData, FakeResponseData.responseOK, nil)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...")
        sut.getFacets { result in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
            case .failure( let error):
                XCTFail("Test failed: \(error)")
                return
            }
       
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
  
    //MARK: VI getPoi  test invalidData
    
    func  testDataIsIncorrect_WhenGetPoiThenReceiveUndecodableData(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlPoi: (FakeResponseData.incorrectData, FakeResponseData.responseOK, nil)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...change threat")
        sut.getPoi(for: "arbre" , nbRecords:100) { result in
            
            guard case .failure(let error) = result else {
                XCTFail("Test failed: \(#function)")
                return
            }
            XCTAssertTrue(error == .undecodableData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    //MARK: VII. getPois  test invalidResponse
    
    func  testInvalidResponse_WhengetPoi_ThenReceiveInvalidResponse(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlPoi: (FakeResponseData.poiCorrectData, FakeResponseData.responseKO, nil)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...")
        sut.getPoi(for: "arbre" , nbRecords:100) {  result in
            
            guard case .failure(let error) = result else {
                XCTFail("Test failed: \(#function)")
                return
            }
            XCTAssertTrue(error == .invalidResponse)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    //MARK: VIII. getPois test .nodata
    
    func  testNoData_WhenPoiDataIsNull_ThenReceiveNoData(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlPoi: (nil, FakeResponseData.responseOK, FakeResponseData.error)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...")
        sut.getPoi(for: "arbre" , nbRecords:100) { result in
            
            guard case .failure(let error) = result else {
                XCTFail("Test failed: \(#function)")
                return
            }
            XCTAssertTrue(error == .noData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    //MARK: IX  getPois test data and response are OK
    
    func  testData_WhenPoiDataIsCorrect_ThenReceiveData(){
        
        URLProtocolFake.fakeURLs = [FakeResponseData.urlPoi: (FakeResponseData.poiCorrectData, FakeResponseData.responseOK, nil)]
        let fakeSession = URLSession(configuration: sessionConfiguration)
        let sut: DataSetService = .init(session: fakeSession)
        
        let expectation = XCTestExpectation(description: "Waiting...")
        sut.getPoi(for: "arbre" , nbRecords:100) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
            case .failure( let error):
                XCTFail("Test failed: \(error)")
                return
            }
       
           
          
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
 
}

