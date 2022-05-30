//
//  ConfirmPhotoView.swift
//  ClassifiedAlbum
//
//  Created by Kohei Ikeda on 2022/05/30.
//

import SwiftUI
import CoreML
import Vision

struct ConfirmPhotoView: View {
    // ManagedObjectContext. CoreDataの操作に必要
    @Environment(\.managedObjectContext) private var viewContext
    // 確認画面の開閉状態を管理
    @Binding var isShowSheet: Bool
    // 表示する写真
    let captureImage: UIImage
    
    // 分類結果の表示テキスト
    @State var classText_1 = ""
    @State var classText_2 = ""
    
    @State var classIdentifier_1 = ""
    @State var classIdentifier_2 = ""
    
    var body: some View {
        VStack {
            Spacer()
            // 分類結果のラベル
            Text(classText_1)
                .multilineTextAlignment(.center)
                .font(.body)
            Text(classText_2)
                .multilineTextAlignment(.center)
                .font(.body)
            
            // スペース
            Spacer()
            // 選択した写真を表示
            Image(uiImage: captureImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            // スペース
            Spacer()
            // 追加するボタン
            Button(action: {
                // 写真をデータベースに保存
                addPhoto(uiImage: captureImage, label_1: classIdentifier_1, label_2: classIdentifier_2)
                isShowSheet = false
            }) {
                Text("この写真をアルバムに追加")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
            } // Button
            .padding()

            // キャンセルボタン
            Button(action: {
                // キャンセル処理
                isShowSheet = false
            }) {
                Text("キャンセル")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.gray)
                    .foregroundColor(Color.white)
            } // Button
            .padding()
        } // VStack
        // Viewが表示された一回だけ
        .onAppear {
            // 分類を行う
            classifyImage(image: captureImage)
        }
    } // body
    
    // 画像を分類
    func classifyImage(image: UIImage) {
        // UIImage -> CIImage
        guard let ciImage = CIImage(image: image) else {
            fatalError("CIImageに変換できません")
        }
        // ハンドラ
        let handler = VNImageRequestHandler(ciImage: ciImage)
        // リクエスト生成
        let classificationRequest = createClassificationRequest()
        do {
            try handler.perform([classificationRequest])
        } catch {
            fatalError("画像分類に失敗しました")
        }
    }
    
    // リクエストを生成
    func createClassificationRequest() -> VNCoreMLRequest {
        do {
            // 設定
            let configuration = MLModelConfiguration()
            // モデルの読み込み
            // let model = try VNCoreMLModel(for: MobileNetV2(configuration: configuration).model)
            let model = try VNCoreMLModel(for: Resnet50(configuration: configuration).model)
            // リクエスト生成
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                // 画像分類の処理
                performClassification(request: request)
            })
            return request
        } catch {
            fatalError("モデル読み込み失敗")
        }
    }
    
    // 画像処理の分類
    func performClassification(request: VNRequest) {
        // 結果を取得
        guard let results = request.results else {
            return
        }
        // [VNClassification] にキャスト
        let classification = results as! [VNClassificationObservation]
        let confidence_1 = Int(classification[0].confidence * 100)
        let confidence_2 = Int(classification[1].confidence * 100)
        
        classIdentifier_1 = classification[0].identifier
        classIdentifier_2 = classification[1].identifier
        
        // 分類結果をラベルに表示
        classText_1 = classIdentifier_1 + " " + String(confidence_1) + "%"
        classText_2 = classIdentifier_2 + " " + String(confidence_2) + "%"
    }
    
    // 写真をデータベースに保存
    private func addPhoto(uiImage: UIImage, label_1: String, label_2: String) {
        withAnimation {
            let newItem = Item(context: viewContext)
            // 日付
            newItem.timestamp = Date()
            // UIImage -> Data型に変換
            guard let dataImage = uiImage.jpegData(compressionQuality: 1.0) else {
                // 変換失敗
                print("Data型への変換失敗")
                return
            }
            newItem.image = dataImage
            // ラベル
            newItem.classLabel_1 = label_1
            newItem.classLabel_2 = label_2
            print("写真追加した")
            do {
                // 保存
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    } // addPhoto
}

struct ConfirmPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmPhotoView(isShowSheet: Binding.constant(true), captureImage: UIImage(named: "previewImage")!)
    }
}
