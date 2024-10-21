//
//  ContentView.swift
//  Queryable
//
//  Created by Ke Fang on 2022/12/14.
//

import SwiftUI

struct ContentView: View {
    @State private var goToIndexView = false
    @StateObject var photoSearcher = PhotoSearcher() // Ensure using @StateObject
    @State private var classLabelInput: String = "" // State variable for class label input
    @State private var selectedPhotoId: String? = nil // State variable to track selected photo's ID
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    SearchBarView(photoSearcher: photoSearcher)
                    
                    // TextField for class label input
                    if selectedPhotoId != nil {
                        TextField("Enter class label", text: $classLabelInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .onSubmit {
                                if let photoId = selectedPhotoId {
                                    if let index = photoSearcher.photoAssets.firstIndex(where: { $0.id == photoId }) {
                                        photoSearcher.photoAssets[index].classLabel = classLabelInput
                                        photoSearcher.saveClassLabels() // Save the label
                                    }
                                }
                            }
                    } else {
                        Text("Select a photo to assign a class label.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                // List to display and select photos
                List(photoSearcher.photoAssets, id: \.id) { asset in
                    HStack {
                        ThumbnailView(phAsset: asset.phAsset)
                            .frame(width: 50, height: 50)
                            .clipped()
                        VStack(alignment: .leading) {
                            Text(asset.classLabel ?? "No ClassLabel")
                                .font(.subheadline)
                            if let label = asset.classLabel {
                                Text("Class Label: \(label)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                        if selectedPhotoId == asset.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // Makes entire row tappable
                    .onTapGesture {
                        selectedPhotoId = asset.id
                        classLabelInput = asset.classLabel ?? ""
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup {
                    NavigationLink(destination: ConfigView().environmentObject(photoSearcher)) {
                        Label("Config", systemImage: "gearshape")
                            .labelStyle(.iconOnly)
                            .font(.title3)
                            .accessibilityLabel(Text("Config Button"))
                            .accessibilityHint(Text("About Queryable, privacy concerns and feedback contact"))
                    }
                }
            }
            .navigationTitle("Queryable")
            .accessibilityAddTraits(.isHeader)
            .navigationDestination(isPresented: $goToIndexView) {
                BuildIndexView(photoSearcher: photoSearcher)
            }
            .onAppear {
                Task {
                    await photoSearcher.loadPhotos()
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .accentColor(.weakgreen)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
