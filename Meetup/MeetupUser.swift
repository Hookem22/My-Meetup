import Alamofire
import SwiftyJSON

class MeetupUser: NSObject, NSCoding {
    var refreshToken: String
    var accessToken: String
    var expires: NSDate
    static var authorizeUrl: String? {
        if let key = KeychainWrapper.stringForKey("MeetupOAuthKey") {
            let redirectUrl = "MyMeetup://return"
            return "https://secure.meetup.com/oauth2/authorize?client_id=\(key)&response_type=code&redirect_uri=\(redirectUrl)&scope=basic+rsvp"
        } else {
            return nil
        }
    }
    
    init(json: JSON) {
        self.refreshToken = json["refresh_token"].stringValue
        self.accessToken = json["access_token"].stringValue
        let expiresIn = json["expires_in"].doubleValue
        self.expires = NSDate(timeIntervalSinceNow: expiresIn)
    }
    
    required init(coder aDecoder: NSCoder) {
        refreshToken = aDecoder.decodeObjectForKey("refreshToken") as! String
        accessToken = aDecoder.decodeObjectForKey("accessToken") as! String
        expires = aDecoder.decodeObjectForKey("expires") as! NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(refreshToken, forKey: "refreshToken")
        aCoder.encodeObject(accessToken, forKey: "accessToken")
        aCoder.encodeObject(expires, forKey: "expires")
    }
    
    static func getCurrentUser(completionHandler: ((MeetupUser?)->())) {
        if let currentUser = KeychainWrapper.objectForKey("CurrentUser") as? MeetupUser {
            if currentUser.expires < NSDate() {
                currentUser.refreshAccessToken { user in
                    completionHandler(user)
                }
            }
            else {
                completionHandler(currentUser)
            }
        }
        else {
            completionHandler(nil)
        }
    }
    
    static func getAccesToken(code: String, completionHandler: ((MeetupUser)->())) {
        let parameters = [
            "client_id" : KeychainWrapper.stringForKey("MeetupOAuthKey")!,
            "client_secret" : KeychainWrapper.stringForKey("MeetupOAuthSecret")!,
            "grant_type" : "authorization_code",
            "redirect_uri" : "MyMeetup://return",
            "code" : code
        ]
    
        Alamofire.request(.POST, "https://secure.meetup.com/oauth2/access", parameters: parameters)
            .response { request, response, data, error in
            
                print(response?.statusCode)
                if let req = request as NSURLRequest! {
                    print(String(req))
                }
                if let resp = response as NSHTTPURLResponse! {
                    print(resp)
                }
                print(JSON(data: data!))
                
                if response?.statusCode == 200 && data != nil {
                    let json = JSON(data: data!)
                    let currentUser = MeetupUser(json: json)
                    KeychainWrapper.setObject(currentUser, forKey: "CurrentUser")
                    completionHandler(currentUser)
                }
        }
    }
    
    func refreshAccessToken(completionHandler: ((MeetupUser?)->())) {
        let parameters = [
            "client_id" : KeychainWrapper.stringForKey("MeetupOAuthKey")!,
            "client_secret" : KeychainWrapper.stringForKey("MeetupOAuthSecret")!,
            "grant_type" : "refresh_token",
            "refresh_token" : self.refreshToken
        ]
        
        Alamofire.request(.POST, "https://secure.meetup.com/oauth2/access", parameters: parameters)
            .response { request, response, data, error in
                
                if response?.statusCode == 200 && data != nil {
                    let json = JSON(data: data!)
                    let currentUser = MeetupUser(json: json)
                    KeychainWrapper.setObject(currentUser, forKey: "CurrentUser")
                    completionHandler(currentUser)
                }
                else {
                    completionHandler(nil)
                }
        }
    }
    
    func joinEvent(event: Event) {
        let parameters = [
            "agree_to_refund" : "yes",
            "response" : "yes"
        ]
        
        let meetupGroup = KeychainWrapper.stringForKey("MeetupGroupName")!
        let url = "https://api.meetup.com/\(meetupGroup)/events/\(event.id)/rsvps"
        
        Alamofire.request(.POST, url, parameters: parameters)
            .response { request, response, data, error in
                
                print(response?.statusCode)
                if let resp = response as NSHTTPURLResponse! {
                    print(resp)
                }
                if response?.statusCode == 200 && data != nil {
                    let json = JSON(data: data!)
                    
                    print(json)
                    
                }
        }    }
}
