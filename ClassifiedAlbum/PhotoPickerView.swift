//
//  PhotoPickerView.swift
//  ClassifiedAlbum
//
//  Created by Kohei Ikeda on 2022/05/25.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    // ManagedObjectContext. CoreDataの操作に必要
    @Environment(\.managedObjectContext) private var viewContext
    
    // フォトライブラリ画面（sheet）の開閉状態を管理
    @Binding var isShowSheet: Bool
    
    // フォトライブラリから読み込む写真
    @Binding var captureImage: UIImage?
    
    // Coordinatorでコントローラのdelegateを管理
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // PhotoPickerView型の変数を用意
        var parent: PhotoPickerView
        // イニシャライザ
        init(parent: PhotoPickerView) {
            self.parent = parent
        }
        // フォトライブラリで写真を選択した時に実行されるdelegateメソッド（必須）
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // 写真は一つだけ選べる設定なので、最初に一件を取得
            if let result = results.first {
                // UIImage型の写真のみを非同期で取得
                result.itemProvider.loadObject(ofClass: UIImage.self) {
                    (image, error) in
                    // UIImage型に条件付きキャスト
                    if let unwrapImage = image as? UIImage {
                        // 選択された写真を追加する
                        self.parent.captureImage = unwrapImage
                        // 写真をCoreDataに保存
                        // self.parent.addPhoto(uiImage: unwrapImage)
                    } else {
                        print("キャスト失敗")
                    }
                } // loadObject
                // sheetを閉じない
                parent.isShowSheet = true
            } else {
                print("選択された写真はありません")
                parent.isShowSheet = false
            }
            // sheetを閉じる
            // parent.isShowSheet = false
        }
    } // Coordinator
    
    // UIViewControllerRepresentableプロトコルのメソッド
    // SwiftUIによって自動的に呼び出し、Coordinatorを生成
    func makeCoordinator() -> Coordinator {
        // Coordinatorクラスのインスタンスを生成
        Coordinator(parent: self)
    }
    
    // Viewを生成するタイミングで自動的に呼び出し
    // PHPickerViewControllerのインスタンスを生成し、設定を行う
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPickerView>) -> PHPickerViewController {
        // PHPickerViewControllerのカスタマイズ
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        // フォトライブラリで選択できる枚数 = 1枚
        configuration.selectionLimit = 1
        // PHPickerViewControllerのインスタンスを生成
        let picker = PHPickerViewController(configuration: configuration)
        // coordinatorをdelegateに設定
        picker.delegate = context.coordinator
        // PHPickerViewControllerを返す
        return picker
    }
    
    // Viewが更新された時に実行
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotoPickerView>) {
        // 処理なし
    }
    
    // 写真をアルバムに追加
    /*
    private func addPhoto(uiImage: UIImage) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            // UIImage -> Data型に変換
            guard let dataImage = uiImage.jpegData(compressionQuality: 1.0) else {
                // 変換失敗
                print("Data型への変換失敗")
                return
            }
            newItem.image = dataImage
            print("写真追加した")
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
     */
}
