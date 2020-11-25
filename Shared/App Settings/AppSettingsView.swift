//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI
import TelemetryClient

struct AppSettingsView: View {
    @EnvironmentObject var api: APIRepresentative

    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    @State var newName: String = ""
    @Binding var sidebarElement: SidebarElement?
    
    var body: some View {
        if let app = app {


            Form {
                Section(header: Text("App Name")) {
                    TextField("App Name", text: $newName)
                }

                Section(header: Text("Unique Identifier")) {
                    VStack(alignment: .leading) {
                        Button (app.id.uuidString) {
                            saveToClipBoard(app.id.uuidString)
                        }
                        Text("Tap to copy this UUID into your apps for tracking.").font(.footnote)
                    }
                }

                Section(header: Text("Delete")) {
                    Button("Delete App \"\(app.name)\"") {
                        api.delete(app: app)
                        TelemetryManager.shared.send(TelemetrySignal.telemetryAppDeleted.rawValue, for: api.user?.email)
                    }.accentColor(.red)
                }

                Button("Save Changes") {
                    api.update(app: app, newName: newName)
                    TelemetryManager.shared.send(TelemetrySignal.telemetryAppUpdated.rawValue, for: api.user?.email)
                }
                .keyboardShortcut(.defaultAction)

                Button("New Insight Group") {
                    api.create(insightGroupNamed: "New Insight Group", for: app) { result in
                        switch result {

                        case .success(let insightGroup):
                            sidebarElement = SidebarElement.insightGroup(id: insightGroup.id)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }

                    }
                }

            }
            .onAppear {
                newName = app.name
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppSettingsShown.rawValue, for: api.user?.email)
                
                // UITableView.appearance().backgroundColor = .clear
            }
        } else {
            Text("No App")
        }
    }
}
