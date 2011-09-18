mongo = require 'mongodb'
db = new mongo.Db('test', new mongo.Server("127.0.0.1", 27017, {}))
data = {}
fb = require 'facebook-js'
db.open (err,db) ->
  require('zappa') {db,fb},->
    use 'static'
    enable 'serve jquery'

    def fbapi: require 'facebook-api'
    def appid: "151280421549911"
    def secret: "a4159d959f722a18b097fff418e0148e"
    def fs: require 'fs'
    def hashlib: require 'hashlib'
    def _: (require 'underscore')._
    class id_accessible
      constructor: (@db,@type) ->
      save: (obj,cb) ->
        @db.collection @type,(err,collection) ->
          collection.update
            id:obj.id
            obj
            upsert: true
          cb?()
      get: (id,cb) ->
        @db.collection @type,(err,collection) ->
          collection.findOne(id:id,cb)
      all: (cb) ->
        @db.collection @type,(err,collection) ->
          collection.find().toArray(cb)
    users = new id_accessible db,'users'
    teams = new id_accessible db,'teams'
    def users: users
    def teams: teams

    #teams.all((err,t) -> console.log t)
    #teams.get(0,(err,t) -> console.log t)

    def secure_association_dictionary: {}

    #db.collection 'users',(err,collection) -> users = collection
    ###
    teams.save
      id: 0
      name: 'A Name'
      team_members: ['Jim Grandpre','Alexey Komissarouk']
      url: 'http://www.url.com'
      video: "BnDH-RXCptY"
      description: 'This is my app!'

    teams.save
      id: 1
      name: 'A Name'
      team_members: ['Tim Lastname','Ayaka Firstname']
      url: 'http://www.link.com'
      video: "BnDH-RXCptY"
      description: 'This is their app!'

    teams.save
      id: 2
      name: 'A Name'
      team_members: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
      url: 'http://www.website.com'
      video:"BnDH-RXCptY"
      description: 'Yet more application code produced by hacking hackery hacker hacks.'

    teams.save
      id: 3
      name: 'A Name'
      team_members: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
      url: 'http://www.xkcd.com'
      video: "BnDH-RXCptY"
      description: 'Webcomics appropriately represented'

    teams.save
      id: 4
      name: 'A Name'
      team_members: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
      url: 'http://www.alexeymk.com'
      video: "BnDH-RXCptY"
      description: 'This is a list of things which make me rather irate'

    teams.save
      id: 5
      name: 'A Name'
      team_members: ['Four Score','And Seven','Years Ago']
      url: 'http://www.constitution.com'
      video: "BnDH-RXCptY"
      description: 'Governmental refrences tickle my fancy'

    teams.save
      id: 6
      name: 'A Name'
      team_members: ['Presnted With','Much Elequonce','Product Sucked']
      url: 'http://www.whartoniteseekscodemonkey.com'
      video: "BnDH-RXCptY"
      description: 'Fantastically useless in every possible way.'

    teams.save
      id: 7
      name: 'A Name'
      team_members: ['Jim Grandpre','Alexey Komissarouk']
      url: 'http://www.url.com'
      video: "BnDH-RXCptY"
      description: 'This is my app!'

    teams.save
      id: 8
      name: 'A Name'
      team_members: ['Tim Lastname','Ayaka Firstname']
      url: 'http://www.link.com'
      video: "BnDH-RXCptY"
      description: 'This is their app!'

    teams.save
      id: 9
      name: 'A Name'
      team_members: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
      url: 'http://www.website.com'
      video: "BnDH-RXCptY"
      description: 'Yet more application code produced by hacking hackery hacker hacks.'

    teams.save
      id: 10
      name: 'A Name'
      team_members: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
      url: 'http://www.xkcd.com'
      video: "BnDH-RXCptY"
      description: 'Webcomics appropriately represented'

    teams.save
      id: 11
      name: 'A Name'
      team_members: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
      url: 'http://www.alexeymk.com'
      video: "BnDH-RXCptY"
      description: 'This is a list of things which make me rather irate'

    teams.save
      id: 12
      name: 'A Name'
      team_members: ['Four Score','And Seven','Years Ago']
      url: 'http://www.constitution.com'
      video: "BnDH-RXCptY"
      description: 'Governmental refrences tickle my fancy'

    teams.save
      id: 13
      name: 'A Name'
      team_members: ['Presnted With','Much Elequonce','Product Sucked']
      url: 'http://www.whartoniteseekscodemonkey.com'
      video: "BnDH-RXCptY"
      description: 'Fantastically useless in every possible way.'
    ###

    get '/': ->

      teams.all (err,t) =>
        @teams = t
        render 'index', layout: no

    get '/auth': ->
      redirect fb.getAuthorizeUrl
        client_id: appid
        redirect_uri: 'http://localhost:3000/auth2'
        scope: 'email, user_education_history'

    get '/auth2': ->
      fb.getAccessToken appid,secret,@code,'http://localhost:3000/auth2',
        (err,access_token, refresh_token) =>
          cl = fbapi.user(access_token)
          cl.me.info (err,data) ->
            token = null
            while !token or secure_association_dictionary[token]?
              token = hashlib.md5 Date()
            console.log data
            is_student = /.edu$/.test(data.email)
            for s in data.education
                if s.type == 'College'
                    if s.year? and s.year.name? and s.year.name > 2011
                        is_student = true
            secure_association_dictionary[token] =
                id: data.id
                is_student: is_student
            redirect "/##{token}"

    at authorize: ->
      console.log @token
      if secure_association_dictionary[@token]?
        {id,is_student} = secure_association_dictionary[@token]
        client.id = id
        users.get id,(err,user) =>
          if err?
            console.error err
            return
          if !user?
            users.save
              id: id
              is_student: is_student
              votes: []
          emit 'authorized',
            votes: user?.votes ? []

    at vote: ->
      if client.id
        users.get client.id,(err,user) =>
          if err
            console.error err
            return
          if !(@id in user.votes)
            user.votes.push(@id)
          users.save user, =>
            emit 'voted',
              id: @id
              client_id: client.id

    at unvote: ->
      if client.id
        users.get client.id,(err,user) =>
          if err
            console.error err
            return
          if (@id in user.votes)
            user.votes = _(user.votes).without(@id)
          users.save user, =>
            emit 'unvoted',
              id: @id
              client_id: client.id
            console.log user

    client '/index.js': ->
      connect()
      $().ready ->
        if window.location.hash != ''
          hash =
            if window.location.hash[0..0] == '#'
              window.location.hash[1...]
            else
              window.location.hash
          emit 'authorize',token: hash
          window.location.hash = ''
        $('button').click ->
          emit 'vote', id: 1
          #emit 'unvote', id: 1


      at voted: ->
        console.log "Voted! #{@client_id} voted for #{@id}"
      at unvoted: ->
        console.log "Unvoted! #{@client_id} voted for #{@id}"
      at authorized: ->
        console.log "I've voted for!",@votes



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