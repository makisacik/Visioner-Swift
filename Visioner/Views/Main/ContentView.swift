//
//  ContentView.swift
//  Visioner
//
//  Created by Mehmet Ali Kısacık on 24.10.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var onboardingManager: OnboardingManager

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisionBoardEntity.createdDate, ascending: false)],
        animation: .default)
    private var boards: FetchedResults<VisionBoardEntity>

    var body: some View {
        NavigationView {
            List {
                ForEach(boards) { board in
                    NavigationLink {
                        Text("Board: \(board.title ?? "Untitled")")
                            .font(.appBody)
                    } label: {
                        Text(board.title ?? "Untitled")
                            .font(.appBody)
                    }
                }
                .onDelete(perform: deleteBoards)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addBoard) {
                        Label("Add Board", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Vision Boards") {
                        VisionBoardGalleryView()
                    }
                    .font(.appButton)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Font Test") {
                        FontTestView()
                    }
                    .font(.appCaption)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Debug") {
                        FontDebugView()
                    }
                    .font(.appCaption)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset Onboarding") {
                        onboardingManager.resetOnboarding()
                    }
                    .font(.appCaption)
                }
            }
            Text("Select an item")
                .font(.appSecondary)
        }
    }

    private func addBoard() {
        withAnimation {
            let newBoard = VisionBoardEntity(context: viewContext)
            newBoard.id = UUID()
            newBoard.title = "New Vision Board"
            newBoard.templateId = "sample"
            newBoard.createdDate = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteBoards(offsets: IndexSet) {
        withAnimation {
            offsets.map { boards[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
