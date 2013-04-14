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
    collectionForName: (name) -> new NyaruCollection(name)
        ###
        Get or create a collection.
        :param name: collection name
        :return: NyaruCollection
        ###

window.db = new NyaruDB()


class NyaruCollection
    ###
    Objective-C -> NyaruCollection
    ###
    name: ''

    constructor: (name) ->
        @name = name

    allIndexes: ->
        ###
        [NATIVE]
        call native code -> [NyaruCollection allIndexes]
        :return: ['index name']
        ###
        nyaru.collection.allIndexes collectionName: @name
    createIndex: (index_name) ->
        ###
        [NATIVE]
        call native code -> [NyaruCollection createIndex]
        :param index_name: index name
        ###
        nyaru.collection.createIndex
            collectionName: @name
            indexName: index_name
    removeIndex: (index_name) ->
        ###
        [NATIVE]
        call native code -> [NyaruCollection removeIndex]
        :param index_name: index name
        ###
        nyaru.collection.removeIndex
            collectionName: @name
            indexName: index_name

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
        :param doc: a new document object
        ###
        nyaru.collection.insert
            collectionName: @name
            document: doc

    where: (index_name, arg={}) ->
        ###
        Generate NyaruQuery
        :param index_name: index name
        :param arg: query operation
            ex:
            equal: '11'
            greater: 12
        ###
        q = new NyaruQuery(@name)
        q.union index_name, arg

    removeAll: ->
        ###
        [NATIVE]
        call native code -> [NyaruCollection removeAll]
        ###
        nyaru.collection.removeAll collectionName: @name


class NyaruQuery
    ###
    Objective-C -> NyaruQuery
    ###
    collection_name: ''
    queries: []

    constructor: (collection_name) ->
        @collection_name = collection_name
        @queries = []

    and: (index_name, arg={}) ->
        ###
        Append NyaruQueryCell
        :param arg:
            equal
            notEqual
            less
            lessEqual
            greater
            greaterEqual
            like
            ex: co.all().and('index_name', equal: 'value')
        :return: NyaruQuery
        ###
        operation = Object.keys arg
        if 'equal' in operation
            @queries.push new NyaruQueryCell(0x40 | 1, index_name, arg.equal)
        else if 'notEqual' in operation
            @queries.push new NyaruQueryCell(0x40, index_name, arg.notEqual)
        else if 'less' in operation
            @queries.push new NyaruQueryCell(0x40 | 2, index_name, arg.less)
        else if 'lessEqual' in operation
            @queries.push new NyaruQueryCell(0x40 | 3, index_name, arg.lessEqual)
        else if 'greater' in operation
            @queries.push new NyaruQueryCell(0x40 | 4, index_name, arg.greater)
        else if 'greaterEqual' in operation
            @queries.push new NyaruQueryCell(0x40 | 5, index_name, arg.greaterEqual)
        else if 'like' in operation
            @queries.push new NyaruQueryCell(0x40 | 0x30, index_name, arg.like)
        @

    union: (index_name, arg={}) ->
        ###
        Append NyaruQueryCell
        :param arg:
            equal
            notEqual
            less
            lessEqual
            greater
            greaterEqual
            like
            ex: co.all().union('index_name', equal: 'value')
        :return: NyaruQuery
        ###
        operation = Object.keys arg
        if 'equal' in operation
            @queries.push new NyaruQueryCell(1, index_name, arg.equal)
        else if 'notEqual' in operation
            @queries.push new NyaruQueryCell(0 , index_name, arg.notEqual)
        else if 'less' in operation
            @queries.push new NyaruQueryCell(2, index_name, arg.less)
        else if 'lessEqual' in operation
            @queries.push new NyaruQueryCell(3, index_name, arg.lessEqual)
        else if 'greater' in operation
            @queries.push new NyaruQueryCell(4, index_name, arg.greater)
        else if 'greaterEqual' in operation
            @queries.push new NyaruQueryCell(5, index_name, arg.greaterEqual)
        else if 'like' in operation
            @queries.push new NyaruQueryCell(0x30, index_name, arg.like)
        @

    orderBy: (index_name) ->
        ###
        Append NyaruQueryCell order by
        :param index_name: index name
        :return: NyaruQuery
        ###
        @queries.push new NyaruQueryCell(0x100, index_name)
        @

    orderByDESC: (index_name) ->
        ###
        Append NyaruQueryCell order by DESC
        :param index_name: index name
        :return: NyaruQuery
        ###
        @queries.push new NyaruQueryCell(0x200, index_name)
        @

    fetch: (limit=0, skip=0) ->
        ###
        [NATIVE]
        call native code -> [NyaruQuery fetch]
        :param limit: result documents limit
        :param skip: result documents skip
        :return: [{document}]
        ###
        nyaru.collection.fetch
            collectionName: @collection_name
            queries: @queries
            skip: skip
            limit: limit

    count: ->
        ###
        [NATIVE]
        call native code -> [NyaruQuery cunt]
        :return: number
        ###
        nyaru.collection.count
            collectionName: @collection_name
            queries: @queries

    remove: ->
        ###
        [NATIVE]
        call native code -> [NyaruQuery remove]
        remove documents that are match this query.
        ###
        nyaru.collection.remove
            collectionName: @collection_name
            queries: @queries


class NyaruQueryCell
    ###
    Objective-C -> NyaruQueryCell
    ###
    schemaName: ''  # index name
    operation: 0    # query operation
    value: ''       # query comparison value

    constructor: (operation, schemaName='', value='') ->
        @schemaName = schemaName
        @operation = operation
        @value = value
