//
//  coreDataManagerTest.swift
//  MontreuilEstNotreJardinTests
//
//  Created by laurent aubourg on 07/02/2022.
//

import XCTest
@testable import MontreuilEstNotreJardin

class coreDataManagerTest: XCTestCase {
    
    var coreDataStack: MockCoreDataStack!
    var coreDataManager: CoreDataManager!
    
    
    override func setUp() {
        super.setUp()
        coreDataStack = MockCoreDataStack()
        coreDataManager = CoreDataManager(coreDataStack: coreDataStack)
    }
    func testWhenAddCategory_ThenAddCategoryIncategoryEntity()  {
        let numberCategories = coreDataManager?.categories.count
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        
        let val = coreDataManager?.categories.count
        XCTAssert(val! > numberCategories!)
    }
    
    func testWhenDeleteCategory_ThenRemoveCategoryIncategoryEntity()  {
        
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let numberCategories = coreDataManager?.categories.count else {return}
        guard let category = Array(coreDataManager.categories).last else{return}
        coreDataManager.deletecategorie(elem: category)
        guard let val = coreDataManager?.categories.count else{return}
        XCTAssert(val == numberCategories  - 1)
    }
    func testWhenDeleteAllCategory_Thencategories_count_equal_0()  {
        
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        coreDataManager?.addCategorie(name: "pipo2",nbRecords:10,state:"displayed")
        coreDataManager.deleteAllcategories()
        guard let val = coreDataManager?.categories.count else{return}
        XCTAssert(val == 0)
    }
    func testWhenCategoryIsSelected_Then_attrbibue_selected_of_the_entity_is_True()  {
        
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        coreDataManager.selectCategory(category)
        let val:Bool = category.selected
        XCTAssert(val == true)
    }
    func testWhenCategoryIsUnelected_Then_attrbibue_selected_of_the_entity_is_false()  {
        
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        coreDataManager.selectCategory(category)
        coreDataManager.unselectCategory(category)
        let val:Bool = category.selected
        XCTAssert(val == false)
    }
    func testWhenCategoryIsUnselectedAllCategories_Then_attrbibute_selected_of_all_entities_is_false()  {
        
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        coreDataManager?.addCategorie(name: "pipo2",nbRecords:10,state:"displayed")
        guard let category2 = Array(coreDataManager.categories).last else{return}
        coreDataManager.selectCategory(category)
        coreDataManager.selectCategory(category2)
        let categoriseSelected = coreDataManager.selectedCategories?.count
        coreDataManager.unselectAllCategory()
        let val = coreDataManager.selectedCategories?.count
        XCTAssert(categoriseSelected == 2 && val == 0)
    }
    func testWhenAddPoiToCategory_then_Number_of_poi_in_catgory_Increases_by_1(){
        let field = field(name: "pipo", categorie: "pipo", year: 2020, state: "ok", address: "zzz", email: "", pointgeo:Pointgeo(longitude: 0.0, latitude: 0.0), telephon: nil)
        let record = Record(id:"1",fields: field)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        let initialNbPoi = category.poi?.count
        coreDataManager.addPoi(categorie: category, pois: [records])
        let nbPoi = category.poi?.count
        XCTAssert(nbPoi == 1 && initialNbPoi == 0)
    }
    func testWhenAddPoiToCategoryWithoutpointgeo_then_Number_of_poi_in_catgory_Ino_change(){
        let field = field(name: "pipo", categorie: "pipo", year: 2020, state: "ok", address: "zzz", email: "", pointgeo:nil, telephon: nil)
        let record = Record(id:"1",fields: field)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        let initialNbPoi = category.poi?.count
        coreDataManager.addPoi(categorie: category, pois: [records])
        let nbPoi = category.poi?.count
        XCTAssert(nbPoi == initialNbPoi)
    }
    func testWhenAddPoiToCategoryWithoutfields_then_Number_of_poi_in_catgory_Ino_change(){
        
        let record = Record(id:"1",fields: nil)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        let initialNbPoi = category.poi?.count
        coreDataManager.addPoi(categorie: category, pois: [records])
        let nbPoi = category.poi?.count
        XCTAssert(nbPoi == initialNbPoi)
    }
    func testWhendGetPoiByLocation_then_returnPoi(){
        let long = 2.4216806
        let lat = 48.851887
        let field = field(name: "testWhendGetPoiByLocation", categorie: "pipo", year: 2020, state: "ok", address: "zzz", email: "", pointgeo:Pointgeo(longitude: long, latitude: lat), telephon: nil)
        let record = Record(id:"1",fields: field)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return}
        coreDataManager.addPoi(categorie: category, pois: [records])
        guard let poi = coreDataManager.getPoiByLocation(longitude: long, latitude: lat) else{
            XCTAssert(false)
            return
            
        }
        XCTAssert(poi.name == "testWhendGetPoiByLocation")
    }
    func testWhendGetPoiByLocationWithBadLocation_then_returnNil(){
        let poi = coreDataManager.getPoiByLocation(longitude: -10, latitude: -10)
        XCTAssert(poi == nil)
    }
    func testWhenAddPoiToFavoritsWithoutPoi_ThenfavoritesAreIncreased(){
        coreDataManager.addPoiToFavorit(poi: nil)
    }
    func testWhenAddPoiToFavorits_ThenfavoritesAreIncreased(){
        let initialNumOfFavorits = coreDataManager.favoritesPois.count
        let field = field(name: "pipo", categorie: "pipo", year: 2020, state: "ok", address: "zzz", email: "", pointgeo:Pointgeo(longitude: 1.0, latitude: 1.0), telephon: nil)
        let record = Record(id:"1",fields: field)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return }
        coreDataManager.addPoi(categorie: category, pois: [records])
        let poiFav = coreDataManager.getPoiByLocation(longitude: 1.0, latitude: 1.0)
        coreDataManager.addPoiToFavorit(poi: poiFav)
        XCTAssert(coreDataManager.favoritesPois.count > initialNumOfFavorits)
    }
    func testWhenRemovePoiToFavoritsWithoutPoi_ThenfavoritesAreIncreased(){
        coreDataManager.removePoiToFavorit(poi: nil)
    }
    func testWhenRemovePoiToFavorits_ThenfavoritesAreIncreased(){
      
        let field = field(name: "pipo", categorie: "pipo", year: 2020, state: "ok", address: "zzz", email: "", pointgeo:Pointgeo(longitude: 1.0, latitude: 1.0), telephon: nil)
        let record = Record(id:"1",fields: field)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return }
        coreDataManager.addPoi(categorie: category, pois: [records])
        let poiFav = coreDataManager.getPoiByLocation(longitude: 1.0, latitude: 1.0)
        coreDataManager.addPoiToFavorit(poi: poiFav)
        let initialNumOfFavorits = coreDataManager.favoritesPois.count
        coreDataManager.removePoiToFavorit(poi: poiFav)
        XCTAssert(coreDataManager.favoritesPois.count < initialNumOfFavorits)
    }
    func testWhengetCategoryPinIcon_ThenReturnIconStringName(){
              XCTAssert(!coreDataManager.getCategoryPinIcon("Arbre à fruits comestibles").isEmpty )
    }
    func testWhenGetCategoryPinIcon_WithUNknowCategoryName_ThenReturnIconStringName(){
              XCTAssert(!coreDataManager.getCategoryPinIcon("xyzß").isEmpty )
    }
    func testWhenGetlistOfPoi_ThenReturnListOfOiSentities(){
        let field = field(name: "pipo", categorie: "pipo", year: 2020, state: "ok", address: "zzz", email: "", pointgeo:Pointgeo(longitude: 1.0, latitude: 1.0), telephon: nil)
        let record = Record(id:"1",fields: field)
        let records:Records = Records(record: record)
        coreDataManager?.addCategorie(name: "pipo",nbRecords:10,state:"displayed")
        guard let category = Array(coreDataManager.categories).last else{return }
        coreDataManager.addPoi(categorie: category, pois: [records])
        XCTAssert(coreDataManager.pois.count == 1)
    }
    func testWhenGetlistOfPoiIfNoPoiRegistred_ThenReturnemptyArray(){
      
        XCTAssert(coreDataManager.pois.count == 0)
    }
}
