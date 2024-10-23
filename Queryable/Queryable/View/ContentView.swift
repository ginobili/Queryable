//
//  ContentView.swift
//  Queryable
//
//  Created by Ke Fang on 2022/12/14.
//

import SwiftUI

struct ContentView: View {
    @State private var goToIndexView = false
    @StateObject var photoSearcher = PhotoSearcher()
    @State private var classLabelInput: String = ""
    @State private var selectedPhotoIds: Set<String> = []

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    SearchBarView(photoSearcher: photoSearcher)
                    
                    if !selectedPhotoIds.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Assign Class Label to Selected Photos")
                                .font(.headline)
                            
                            TextField("Enter class label", text: $classLabelInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 5)
                                .onSubmit {
                                    assignClassLabel()
                                }
                            
                            Button(action: assignClassLabel) {
                                Text("Assign Label")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(classLabelInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.vertical)
                    } else {
                        Text("Select one or more photos to assign a class label.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                // Display search results
                List(photoSearcher.searchResultPhotoAssets, id: \.id, selection: $selectedPhotoIds) { asset in
                    HStack {
                        ThumbnailView(phAsset: asset.phAsset)
                            .frame(width: 50, height: 50)
                            .clipped()
                        
                        VStack(alignment: .leading) {
                            // Ensure this Text view is displaying the updated class label
                            Text(asset.classLabel ?? "No Description")
                                .font(.subheadline)
                            
                            if let label = asset.classLabel {
                                Text("Class Label: \(label)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        if selectedPhotoIds.contains(asset.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(for: asset.id)
                        if selectedPhotoIds.contains(asset.id) {
                            classLabelInput = asset.classLabel ?? ""
                        } else {
                            classLabelInput = ""
                        }
                    }
                }
                .toolbar {
                    EditButton()
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
                    await photoSearcher.prepareModelForSearch()
                    await photoSearcher.loadPhotos()
                    if photoSearcher.buildIndexCode == .PHOTOS_LOADED {
                        goToIndexView = true
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .accentColor(.weakgreen)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    private func toggleSelection(for photoId: String) {
        if selectedPhotoIds.contains(photoId) {
            selectedPhotoIds.remove(photoId)
        } else {
            selectedPhotoIds.insert(photoId)
        }
    }
    
    private func assignClassLabel() {
        print("assignClassLabel called")
        let trimmedLabel = classLabelInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLabel.isEmpty else { return }
        
        for photoId in selectedPhotoIds {
            photoSearcher.assignClassLabel(to: photoId, with: trimmedLabel)
        }
        photoSearcher.saveClassLabels()
        classLabelInput = ""
        selectedPhotoIds.removeAll()
    }
}
