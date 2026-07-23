import Foundation

import DynamicSignatureApplication
import DynamicSignatureInfrastructure
import DynamicSignatureDomain


@MainActor
final class AppContainer:
    ObservableObject {


    let service:
        SignatureService



    init() {


        let directory =
            StorageDirectory(
                baseURL:
                    FileManager.default
                    .applicationSupportDirectory
            )


        try? directory
            .createIfNeeded()



        let store =
            SignatureDataStore(
                directory:
                    directory
            )



        let quoteRepository =
            QuoteJSONRepository(
                repository:
                    store.quotes
            )


        let identityRepository =
            IdentityJSONRepository(
                repository:
                    store.identities
            )


        let profileRepository =
            ProfileJSONRepository(
                repository:
                    store.profiles
            )


        let historyRepository =
            HistoryJSONRepository(
                repository:
                    JSONRepository(
                        fileURL:
                            directory.url
                            .appending(
                                path:
                                "history.json"
                            )
                    )
            )



        let quotes =
            try? quoteRepository.allQuotes()



        let engine =
            QuoteSelectionEngine(
                quotes:
                    quotes ?? []
            )



        let generator =
            GenerateSignatureUseCase(

                profiles:
                    profileRepository,

                identities:
                    identityRepository,

                quotes:
                    quoteRepository,

                history:
                    historyRepository,

                quoteEngine:
                    engine
            )


        service =
            SignatureService(
                generator:
                    generator
            )
    }
}
