
import XCTest
import Alamofire
@testable import Meetup

class EventTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetIsEmpty() {
        let expectation = expectationWithDescription("Get")
        
        Event.get { events in
            XCTAssertNotNil(events, "Expected events non-nil")
            XCTAssert(events.count > 0, "Expected more than 0 events")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGetProperties() {
        let expectation = expectationWithDescription("Get")
        
        Event.get { events in

            for event in events {
                let mirroredEvent = Mirror(reflecting: event)
                for (index, attr) in mirroredEvent.children.enumerate() {
                    if let propName = attr.label as String! {
                        XCTAssertNotNil(attr.value, "Event attr \(index): \(propName) is nil")
                    }
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)

    }
    
    func testGetVenue() {
        let expectation = expectationWithDescription("Get")
        
        Event.get { events in
            for event in events {
                let mirroredEvent = Mirror(reflecting: event)
                for (_, attr) in mirroredEvent.children.enumerate() {
                    if let propName = attr.label as String! where propName == "venue" {
                        let mirroredVenue = Mirror(reflecting: attr)
                        for (venueIndex, venueAttr) in mirroredVenue.children.enumerate() {
                            if let venuePropName = venueAttr.label as String! {
                                XCTAssertNotNil(attr.value, "Venue attr \(venueIndex): \(venuePropName) is nil")
                            }
                        }
                    }
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)

    }
    
}
