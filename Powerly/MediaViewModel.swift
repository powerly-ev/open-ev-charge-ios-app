//
//  MediaViewModel.swift
//  PowerShare
//
//  Created by ADMIN on 31/07/23.
//  
//

import Foundation
import RxSwift

class MediaViewModel: @unchecked Sendable {
    var medias = BehaviorSubject(value: [Media]())
    var localMedias = BehaviorSubject(value: [Data]())
    
    func appendLocalMedia(image: [Data]) {
        if var medias = try? self.localMedias.value() {
            medias.append(contentsOf: image)
            self.localMedias.onNext(medias)
        } else {
            self.localMedias.onNext(image)
        }
    }
    
    func deleteLocationMedia(index: Int) {
        if var medias = try? self.localMedias.value(), medias.indices.contains(index) {
            medias.remove(at: index)
            self.localMedias.onNext(medias)
        }
    }
    
    func getMediaOfStation(id: String) {
        MediaService().getPowerSourceMediaList(id: id) { _, _, medias in
            self.medias.onNext(medias)
        }
    }
    
    func uploadImages(id: String, datas: [Data]) async -> (Int, String) {
        CommonUtils.showProgressHud()
        let response = try? await MediaService().addMediaToPowerSource(id: id, title: "", medias: datas)
        CommonUtils.hideProgressHud()
        if let response = response, response.statusCode == 1 {
            self.medias.onNext(response.mediaList)
        }
        return (response?.statusCode ?? 0, response?.message ?? "")
    }
    
    func deleteMedia(id: String, mediaId: Int) {
        CommonUtils.showProgressHud()
        MediaService().deleteMediaFromPowersource(id: id, mediaId: mediaId) { success, _, medias in
            CommonUtils.hideProgressHud()
            if success == 1 {
                self.medias.onNext(medias)
            }
        }
    }
}
