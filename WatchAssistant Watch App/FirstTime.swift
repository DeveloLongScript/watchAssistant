// Licensed under the MIT License, created by DeveloLongScript on GitHub

import SwiftUI
import PromiseKit
import AuthenticationServices
 var authCode = ""
struct WelcomePage: View {
    var body: some View {
        ScrollView {
            // TODO: Add icon
            Image(systemName: "house.circle.fill").symbolRenderingMode(.hierarchical).foregroundStyle(Color.purple) .font(.system(size: 60))
            Text("Welcome!").font(.system(size: 20)).fontWeight(.bold)
            Text("Watch Assistant is an Watch app to integrate Home Assistant")
            NavigationLink("Start", destination: ServerList()).tint(.purple)
            Spacer()
            Text("Q/A:")
            Text("Q: Why is Watch Assistant nesscary when we already have a Home Assistant watch app.").fontWeight(.bold)
            Text("A: Home Assistant needs a phone to operate, and even then, all you can do is use pre-existing actions. You can turn on and off every light to whatever color you would like, while Home Assistant can't.")
            Text("Q: This isn't offical, will this hack me? A: No, Watch Assistant is open source").fontWeight(.bold)
            SettingsButton()
        }.navigationBarBackButtonHidden(true)
    }
}

struct SettingsButton: View {
    var body: some View {
        Spacer()
        NavigationLink(destination: MinimalSettings(), label: {
            Image(systemName: "gear")
        }).tint(.purple)
    }
}

struct UnOfficalWarning: View {
    @State private var willMoveToSL = false
    var body: some View {
        ScrollView {
            Text("Warning:")
                .foregroundColor(.yellow)
            Text("This app wasn't offically made by Home Assistant. If you need support, use the 'Support' button in the Settings.           ").fixedSize(horizontal: false, vertical: true)
            Spacer()
            NavigationLink(destination: WelcomePage()) {
                Text("Okay")
            }.simultaneousGesture(TapGesture().onEnded{
                savedValues.warningRemoved = true
                SaveData()
            })
        }
    }
}

struct ServerList: View {
    @State private var loaded = false
    @State private var defDisable = false
    @State private var isClicked = false
    var body: some View {
        VStack {
            if loaded == true {
                VStack {
                    Image(systemName: "tv.circle.fill").symbolRenderingMode(.hierarchical).foregroundStyle(Color.purple) .font(.system(size: 60))
                    Text("Pick a instance").font(.system(size: 20)).fontWeight(.bold)
                    List {
                        
                        Button("Use the default HA server") {
                            // Use the URL and callback scheme specified by the authorization provider.
                            guard let authURL = URL(string: "http://homeassistant.local:8123/auth/authorize?client_id=https%3A%2F%2Fdevelolongscript.github.io&redirect_uri=https%3A%2F%2Fdevelolongscript.github.io%2FwatchAssistant-callback%2F") else { return }
                            let scheme = "wais"


                            // Initialize the session.
                            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme)
                            { callbackURL, error in
                                // Handle the callback.
                                if callbackURL != nil {
                                    let urlMinusScheme = callbackURL?.absoluteString.replacingOccurrences(of: "^wais?://", with: "", options: .regularExpression)
                                    tempValues.startToken = urlMinusScheme!
                                    savedValues.host = "http://homeassistant.local:8123"
                                    SaveData()
                                    isClicked.toggle()
                                }
                                
                                
                            }
                            session.start()
                        }.disabled(defDisable)
                        NavigationLink("Use a custom server", destination: CustomView())
                    }
                }
            } else {
                ProgressView()
            }
        }.navigationDestination(isPresented: $isClicked, destination: {AuthenticatedView()}).onAppear(perform: {
            
            let url = URL(string: "http://homeassistant.local:8123")!
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                        loaded = true
                } else if error != nil {
                        defDisable = true
                        loaded = true
                    }
                loaded = true
            }.resume()
        })
    }
}

struct AuthenticatedView: View {
    var token = tempValues.startToken
    
    var body: some View {
        ProgressView().navigationBarBackButtonHidden(true).navigationTitle("Authenticating.....").onAppear {
            let token = tempValues.startToken
            let url = URL(string: savedValues.host + "/auth/token")!
            var requestBodyComponents = URLComponents()
            print(token)
            requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"),
                                                URLQueryItem(name: "code", value: tempValues.startToken),
                                                URLQueryItem(name: "client_id", value: "https://develolongscript.github.io")]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                 var decoded = try? JSONDecoder().decode(AuthenticationObject.self, from: data!)
                var request = URLRequest(url: URL(string: savedValues.host + "/api/states")!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("Bearer \(decoded!.access_token)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    var decoded = try? JSONDecoder().decode([StateObject].self, from: data!)
                    print(decoded?.first?.last_changed)
                }.resume()
            }.resume()
        }
    }
}


struct CustomView: View {
    @State private var tftext = ""
    var body: some View {
        ScrollView {
            Text("IP cannot start with http://, ports need to be included.")
            TextField("HA Server", text: $tftext).onSubmit {
                
            }
            Spacer()
            Button("Done") {}.backgroundStyle(.purple)
        }.navigationTitle("Type a server")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        UnOfficalWarning()
    }
}
