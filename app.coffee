mongo = require 'mongodb'
db = new mongo.Db('test', new mongo.Server("127.0.0.1", 27017, {}))

data = {}

db.open (err,db) ->
  id_accessible = (type) ->
    save: (obj) ->
      db.collection type,(err,collection) ->
         collection.insert(obj)
    get: (id,cb) ->
      db.collection type,(err,collection) ->
        collection.findOne(id:id,cb)

  users = id_accessible 'users'
  teams = id_accessible 'teams'

  #db.collection 'users',(err,collection) -> users = collection
  teams.save
    id: 0
    names: ['Jim Grandpre','Alexey Komissarouk']
    url: 'www.url.com'
    video: "http://www.youtube.com/embed/1Ek4QaFQ1qo"
    description: 'This is my app!'

  teams.save
    id: 1
    names: ['Tim Lastname','Ayaka Firstname']
    url: 'www.link.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'This is their app!'

  teams.save
    id: 2
    names: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
    url: 'www.website.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Yet more application code produced by hacking hackery hacker hacks.'

  teams.save
    id: 3
    names: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
    url: 'www.xkcd.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Webcomics appropriately represented'

  teams.save
    id: 4
    names: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
    url: 'www.alexeymk.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'This is a list of things which make me rather irate'

  teams.save
    id: 5
    names: ['Four Score','And Seven','Years Ago']
    url: 'www.constitution.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Governmental refrences tickle my fancy'

  teams.save
    id: 6
    names: ['Presnted With','Much Elequonce','Product Sucked']
    url: 'www.whartoniteseekscodemonkey.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Fantastically useless in every possible way.'

  teams.save
    id: 7
    names: ['Jim Grandpre','Alexey Komissarouk']
    url: 'www.url.com'
    video: "http://www.youtube.com/embed/1Ek4QaFQ1qo"
    description: 'This is my app!'

  teams.save
    id: 8
    names: ['Tim Lastname','Ayaka Firstname']
    url: 'www.link.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'This is their app!'

  teams.save
    id: 9
    names: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
    url: 'www.website.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Yet more application code produced by hacking hackery hacker hacks.'

  teams.save
    id: 10
    names: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
    url: 'www.xkcd.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Webcomics appropriately represented'

  teams.save
    id: 11
    names: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
    url: 'www.alexeymk.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'This is a list of things which make me rather irate'

  teams.save
    id: 12
    names: ['Four Score','And Seven','Years Ago']
    url: 'www.constitution.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Governmental refrences tickle my fancy'

  teams.save
    id: 13
    names: ['Presnted With','Much Elequonce','Product Sucked']
    url: 'www.whartoniteseekscodemonkey.com'
    video: "http://www.youtube.com/embed/BnDH-RXCptY"
    description: 'Fantastically useless in every possible way.'






  require('zappa') ->
    enable 'serve jquery'

    get '/': ->
      render 'index', layout: no

    at 'set nickname': ->
      client.nickname = @nickname

    at said: ->
      io.sockets.emit 'said', nickname: client.nickname, text: @text

    client '/index.js': ->
      connect()

      at said: ->
        $('#panel').append "<p>#{@nickname} said: #{@text}</p>"

      $().ready ->
        emit 'set nickname', nickname: prompt('Pick a nickname')

      $('button').click ->
        emit 'said', text: $('#box').val()
        $('#box').val('').focus()

    view index: ->
      doctype 5
      html ->
        head ->
          title 'PennApps Voting'
          script src: '/socket.io/socket.io.js'
          script src: '/zappa/jquery.js'
          script src: '/zappa/zappa.js'
          script src: '/index.js'
        body ->
          div id: 'panel'
          input id: 'box'
          button 'Send'