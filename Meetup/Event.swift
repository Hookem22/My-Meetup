import Alamofire
import SwiftyJSON

class Event {
    static let exampleMeetupUrl = "https://api.meetup.com/2/events?offset=0&format=json&limited_events=False&group_urlname=CoFounder-Austin&page=200&fields=&order=time&desc=false&status=upcoming&sig_id=75354252&sig=d3c78ebdaf5dafe5742cf9743093c7cd55556e85"
    
    var id: String
    var name: String
    var description: String
    var rsvpYes: Int
    var rsvpLimit: Int
    var groupUserLabel: String
    var venue: Venue
    var price: String
    var time: Double
    var utcOffset: Int
    var duration: Double
    var startDate: NSDate {
        return NSDate(timeIntervalSince1970: self.time / 1000.0)
    }
    var endDate: NSDate {
        return NSDate(timeIntervalSince1970: (self.time + self.duration) / 1000.0)
    }
    var formattedDate: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d"
        //Already included offset in startDate
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: self.utcOffset)
        return formatter.stringFromDate(startDate)
    }
    var formattedTime: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE h:mm a"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: self.utcOffset)
        return formatter.stringFromDate(startDate)
    }
    var formattedDateTime: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: self.utcOffset)
        return formatter.stringFromDate(startDate)
    }
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.description = json["description"].stringValue
        self.time = json["time"].doubleValue
        self.utcOffset = json["utc_offset"].intValue
        self.duration = json["duration"].doubleValue
        self.rsvpYes = json["yes_rsvp_count"].intValue
        self.rsvpLimit = json["rsvp_limit"].intValue
        self.groupUserLabel = json["group"]["who"].stringValue
        self.venue = Venue(json["venue"])
        if json["fee"].exists()  {
            let amount = json["fee"]["amount"]
            let description = json["fee"]["description"]
            self.price = "$\(amount) \(description)"
        }
        else {
            self.price = ""
        }
    }
    
    static func get(completionHandler: (([Event])->())?) {
        var meetupUrl = self.exampleMeetupUrl
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let meetupGroup = defaults.objectForKey("MeetupGroupName") as? String where meetupGroup != "MEETUP_NAME" {
            if let apiKey = defaults.objectForKey("MeetupAPIKey") as? String where apiKey != "MEETUP_API_KEY" {
                meetupUrl = "https://api.meetup.com/2/events?key=\(apiKey)&group_urlname=\(meetupGroup)"
            }
        }

        Alamofire.request(.GET, meetupUrl)
            .response { request, response, data, error in
                
                var events = [Event]()
                if response?.statusCode == 200 && data != nil {
                    let json = JSON(data: data!)
                    for(_, subJson):(String, JSON) in json["results"] {
                        events.append(Event(json: subJson))
                    }
                }
                completionHandler?(events)
        }
    }
}
