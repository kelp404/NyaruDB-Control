###
    NyaruDB CoffeeScript Interface
    Kelp http://github.com/kelp404

    Created by Kelp on 2013/04/08.
###

$ = jQuery
window.nyaru = window.nyaru || {}

$.extend window.nyaru,
    collection: {
        ### Objective-C code
        allIndexes: ({collectionName}) ->
            [NyaruCollection allIndexes]
        createIndex: ({collectionName, indexName}) ->
            [NyaruCollection createIndex:<#(NSString *)#>]
        removeIndex: ({collectionName, indexName}) ->
            [NyaruCollection removeIndex:<#(NSString *)#>]


        fetch: ({collectionName, queries=[], skip=0, limit=0}) ->
            [NyaruCollection fetchByQuery:<#(NSArray *)#> skip:<#(NSUInteger)#> limit:<#(NSUInteger)#>]

        count: ({collectionName, queries=[]}) ->
            [NyaruCollection countByQuery:<#(NSArray *)#>]

        insert: ({collectionName, document={}}) ->
            [NyaruCollection insert:<#(NSDictionary *)#>]

        remove: ({collectionName, queries=[]}) ->
            [NyaruCollection removeByQuery:<#(NSArray *)#>]

        removeAll: ({collectionName}) ->
            [NyaruCollection removeAll]
        ###
    }
