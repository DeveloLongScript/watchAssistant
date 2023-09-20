// Licensed under the MIT License, created by DeveloLongScript on GitHub

import Foundation

struct AuthenticationObject: Codable {
    let access_token: String;
    let expires_in: Int;
    let refresh_token: String;
    let token_type: String;
}

struct StateObject: Codable {
    let entity_id: String;
    let state: String;
    let attributes: String;
    let last_changed: String;
    let last_updated: String;
    
}
