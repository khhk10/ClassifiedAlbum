//
//  ContentView.swift
//  ClassifiedAlbum
//
//  Created by Kohei Ikeda on 2022/05/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // シートの開閉を管理
    @State var isShowSheet = false
    // アクションシートの開閉を管理
    @State var isShowActionSheet = false
    @State var isPhotolibrary = false
    // アルバムに追加する写真
    @State var captureImage: UIImage? = nil
    // 検索ワード
    @State var searchWord = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        if let imageData = item.image {
                            if let uiImage = UIImage(data: imageData) {
                                // 写真を表示
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                                    .padding()
                            } // if
                        } // if
                        if let labelText = item.classLabel_1 {
                            Text(labelText)
                        }
                    }
                } // ForEach
                .onDelete(perform: deleteItems)
            } // List
            .toolbar {
                // 上のボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                // 下のボタン（写真を追加）
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // captureImageを初期化
                        captureImage = nil
                        isShowActionSheet = true
                    }) {
                        Image(systemName: "camera")
                            .scaleEffect(1.5)
                    }
                    // シート
                    .sheet(isPresented: $isShowSheet) {
                        if let unwrapCaptureImage =  captureImage {
                            // 写真がある場合 -> 確認画面(ConfirmPhotoView)を表示
                           ConfirmPhotoView(isShowSheet: $isShowSheet, captureImage: unwrapCaptureImage)
                        } else {
                            if isPhotolibrary {
                                // フォトライブラリーが選択された
                                PhotoPickerView(isShowSheet: $isShowSheet, captureImage: $captureImage)
                            } else {
                                // カメラが選択された
                            }
                        }
                    }
                    // アクションシート
                    .actionSheet(isPresented: $isShowActionSheet) {
                        ActionSheet(title: Text("写真を追加"),
                                    message: Text("選択してください"),
                                    buttons: [
                                        // フォトライブラリー
                                        .default(Text("フォトライブラリー"), action: {
                                            // フォトライブラリーを表示
                                            isPhotolibrary = true
                                            // シートを表示
                                            isShowSheet = true
                                        }),
                                        // キャンセル
                                        .cancel(),
                                    ]) // ActionSheet
                    } // .actionSheet
                } // ToolbarItem
            } // toolbar
        } // NavigationView
        // 検索バー
        .searchable(
            text: $searchWord,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: Text("検索ワードを入力してください"))
        .onSubmit(of: .search) {
            // 検索バーでEnterを押した時の処理
            searchPhoto(searchWord: searchWord)
        }
    } // body
    
    // ワードから写真を検索
    private func searchPhoto(searchWord: String) {
        if searchWord == "all" {
            items.nsPredicate = nil
        } else {
            items.nsPredicate = NSPredicate(format: "classLabel_1 CONTAINS %@", searchWord)
        }
        print("searchWord: \(searchWord)")
    } // searchPhoto

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    } // deleteItems
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
