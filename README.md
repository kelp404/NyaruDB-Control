#NyaruDB Control


Kelp https://twitter.com/kelp404  
[MIT License][mit]
[MIT]: http://www.opensource.org/licenses/mit-license.php


NyaruDB Control is a management tool for <a href="https://github.com/kelp404/NyaruDB" target="_blank">NyaruDB</a> which is a simple NoSQL database in Objective-C.  

You could use <a href="http://coffeescript.org/" target="_blank">CoffeeScript</a> to execute query.  

<img src='https://raw.github.com/kelp404/NyaruDB-Control/master/_images/screenshot00.png' witdh='850px' height='505px'/>  
(run coffee script: ⌘+R)  



##Installation
```
$ git clone --recursive git://github.com/kelp404/NyaruDB-Control.git
```



##Example
```coffee
# get/create collection 'user'
co = db.collection 'user'

# create index 'name'
co.createIndex 'name'

# put document {name: 'kelp', email:'kelp@phate.org', update:<now>}
co.put name: 'kelp', email: 'kelp@phate.org', update: new Date

# fetch all documents then print
print co.all().fetch()

# search documents which name is 'kelp'
print co.where('name', equal: 'kelp').fetch()

# print all documents count
print co.all().count()
```



##Class
###NyaruDB
```coffee
collection: (name) ->
    ###
    Get or create a collection.
    :param name: collection name
    :return: NyaruCollection
    ###
```


###NyaruCollection
```coffee
### Index ###
allIndexes: ->
    ###
    [NATIVE]
    call native code -> [NyaruCollection allIndexes]
    :return: ['index name']
    ###

createIndex: (index_name) ->
    ###
    [NATIVE]
    call native code -> [NyaruCollection createIndex]
    :param index_name: index name
    ###

removeIndex: (index_name) ->
    ###
    [NATIVE]
    call native code -> [NyaruCollection removeIndex]
    :param index_name: index name
    ###


### Document ###
put: (doc) ->
    ###
    [NATIVE]
    call native code -> [NyaruCollection put]
    :param doc: a new document object
    ###

all: ->
    ###
    Generate NyaruQuery
    ###

where: (index_name, arg={}) ->
    ###
    Generate NyaruQuery
    :param index_name: index name
    :param arg: query operation
        ex:
        equal: '11'
        greater: 12
    ###

removeAll: ->
    ###
    [NATIVE]
    call native code -> [NyaruCollection removeAll]
    ###
```


###NyaruQuery
```coffee
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

orderBy: (index_name) ->
    ###
    Append NyaruQueryCell order by
    :param index_name: index name
    :return: NyaruQuery
    ###

orderByDESC: (index_name) ->
    ###
    Append NyaruQueryCell order by DESC
    :param index_name: index name
    :return: NyaruQuery
    ###

fetch: (limit=0, skip=0) ->
    ###
    [NATIVE]
    call native code -> [NyaruQuery fetch]
    :param limit: result documents limit
    :param skip: result documents skip
    :return: [{document}]
    ###

count: ->
    ###
    [NATIVE]
    call native code -> [NyaruQuery cunt]
    :return: number
    ###

remove: ->
    ###
    [NATIVE]
    call native code -> [NyaruQuery remove]
    remove documents that are match this query.
    ###
```