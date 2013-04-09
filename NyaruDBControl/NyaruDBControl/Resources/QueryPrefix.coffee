###
    NyaruDB CoffeeScript Query Prefix Script
    Kelp http://github.com/kelp404
    
    Created by Kelp on 2013/04/08.
###

# Objective-C code
window.nyaru = window.nyaru || {}


class NyaruDB
    ###
    Objective-C -> NyaruDB
    ###
    collectionForName: (name) ->
        new NyaruCollection(name)
window.db = new NyaruDB()


class NyaruCollection
    ###
    Objective-C -> NyaruCollection
    ###
    name: ''

    # constructor
    constructor: (name) ->
        @name = name
        @

    all: ->
        ###
        Generate NyaruQuery
        ###
        q = new NyaruQuery(@name)
        q.queries.push new NyaruQueryCell(0x80)
        q

    insert: (doc) ->
        ###
        [NATIVE]
        call native code -> [NyaruCollection insert]
        ###
        nyaru.collection.insert
            collectionName: @name
            document: doc


class NyaruQuery
    ###
    Objective-C -> NyaruQuery
    ###
    collection_name: ''
    queries: []

    constructor: (collection_name) ->
        @collection_name = collection_name
        @

    fetch: (skip=0, limit=0) ->
        ###
        [NATIVE]
        call native code -> [NyaruQuery fetch]
        ###
        nyaru.collection.fetch
            collectionName: @collection_name
            queries: @queries
            skip: skip
            limit: limit


class NyaruQueryCell
    ###
    Objective-C -> NyaruQueryCell
    ###
    schemaName: ''
    operation: 0
    value: ''

    constructor: (operation, schemaName='', value='') ->
        @schemaName = schemaName
        @operation = operation
        @value = value
        @
