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
         fetch: ({collectionName, queries=[], skip=0, limit=0}) ->
             [NyaruCollection fetchByQuery:<#(NSArray *)#> skip:<#(NSUInteger)#> limit:<#(NSUInteger)#>]

        insert: ({collectionName, document={}}) ->
             [NyaruCollection insert:<#(NSDictionary *)#>]
         ###
    }
