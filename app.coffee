mongo = require 'mongodb'
db = new mongo.Db('test', new mongo.Server("127.0.0.1", 27017, {}))
data = {}

db.open (err,db) ->
  require('zappa') {db},->
    use 'static'
    enable 'serve jquery'

    class id_accessible
      constructor: (@type) ->
      save: (obj) ->
#        console.log @type
        db.collection @type,(err,collection) ->
          collection.insert(obj)
      get: (id,cb) ->
        console.log @type
        db.collection @type,(err,collection) ->
          collection.findOne(id:id,cb)
      all: (cb) ->
        db.collection @type,(err,collection) ->
          collection.find().toArray(cb)

    users = new id_accessible 'users'
    teams = new id_accessible 'teams'
    def users: users
    def teams: teams

    #teams.all((err,t) -> console.log t)
    #teams.get(0,(err,t) -> console.log t)

    #db.collection 'users',(err,collection) -> users = collection
#    teams.save
#      id: 0
#      names: ['Jim Grandpre','Alexey Komissarouk']
#      url: 'www.url.com'
#      video: "http://www.youtube.com/embed/1Ek4QaFQ1qo"
#      description: 'This is my app!'
#
#    teams.save
#      id: 1
#      names: ['Tim Lastname','Ayaka Firstname']
#      url: 'www.link.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'This is their app!'
#
#    teams.save
#      id: 2
#      names: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
#      url: 'www.website.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Yet more application code produced by hacking hackery hacker hacks.'
#
#    teams.save
#      id: 3
#      names: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
#      url: 'www.xkcd.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Webcomics appropriately represented'
#
#    teams.save
#      id: 4
#      names: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
#      url: 'www.alexeymk.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'This is a list of things which make me rather irate'
#
#    teams.save
#      id: 5
#      names: ['Four Score','And Seven','Years Ago']
#      url: 'www.constitution.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Governmental refrences tickle my fancy'
#
#    teams.save
#      id: 6
#      names: ['Presnted With','Much Elequonce','Product Sucked']
#      url: 'www.whartoniteseekscodemonkey.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Fantastically useless in every possible way.'
#
#    teams.save
#      id: 7
#      names: ['Jim Grandpre','Alexey Komissarouk']
#      url: 'www.url.com'
#      video: "http://www.youtube.com/embed/1Ek4QaFQ1qo"
#      description: 'This is my app!'
#
#    teams.save
#      id: 8
#      names: ['Tim Lastname','Ayaka Firstname']
#      url: 'www.link.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'This is their app!'
#
#    teams.save
#      id: 9
#      names: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
#      url: 'www.website.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Yet more application code produced by hacking hackery hacker hacks.'
#
#    teams.save
#      id: 10
#      names: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
#      url: 'www.xkcd.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Webcomics appropriately represented'
#
#    teams.save
#      id: 11
#      names: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
#      url: 'www.alexeymk.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'This is a list of things which make me rather irate'
#
#    teams.save
#      id: 12
#      names: ['Four Score','And Seven','Years Ago']
#      url: 'www.constitution.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Governmental refrences tickle my fancy'
#
#    teams.save
#      id: 13
#      names: ['Presnted With','Much Elequonce','Product Sucked']
#      url: 'www.whartoniteseekscodemonkey.com'
#      video: "http://www.youtube.com/embed/BnDH-RXCptY"
#      description: 'Fantastically useless in every possible way.'


    get '/': ->
      teams.all (err,t) =>
        @teams = t
        console.log @teams
        render 'index', layout: no

    at 'set nickname': ->
      client.nickname = @nickname

    at said: ->
      io.sockets.emit 'said', nickname: client.nickname, text: @text

    client '/index.js': ->
      connect()

      at said: ->
        $('#panel').append "<p>#{@nickname} said: #{@text}</p>"


      $('button').click ->
        emit 'said', text: $('#box').val()
        $('#box').val('').focus()


    view index: ->
      doctype 5

      team_div = (team) ->
        div class: 'team span-one-third', ->
          a href: team.url, ->
            h3 "Team Name goes Here"
          img
            width: 300
            height: 225
            src: 'http://img.youtube.com/vi/EqWRZrupLrI/0.jpg'#eventually: team.video
            frameborder: 0
          div id: 'vote_for', style: 'float: right;', ->
            p "Vote"
            img
              src: 'checkbox_empty.png'
              name:'vote_tick'
              width: '40'
              height: '40px'
          p class: 'description', ->
            team.description
          p class:'team_members', ->
            result = ""# I know, adding to a string is bad.
            result += member + " | " for member in team.names[...-1]
            result += team.names[-1..][0]
            result
      
      html ->
        head ->
          title 'PennApps Voting'
          script src: '/socket.io/socket.io.js'
          script src: '/zappa/jquery.js'
          script src: '/zappa/zappa.js'
          script src: '/index.js'
          link
            rel: 'stylesheet'
            href: "http://twitter.github.com/bootstrap/1.3.0/bootstrap.min.css"
        body ->
          div class: "container", ->
            h1 "PennApps Voting, Logo goes here"
            h2 "img src goes here for for FRC, UA"
            section id:'grid-system', ->
              for row in [0,1] #@teams.length / 3 in real world
                 div class:'row show-grid', ->
                  team_div t for t in @teams[row*3..row*3+2]
