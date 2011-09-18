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

    def secure_association_dictionary: {}
    get '/': ->

      teams.all (err,t) =>
        shuffle = (input) ->
          swap  = (input, x,  y) -> [input[x], input[y]] = [input[y], input[x]]
          rand  = (x) -> Math.floor(Math.random() * x)
          permute = (input) -> swap(input, i, rand(i)) for i in [input.length-1..1]

          permute input
          return input

        @teams = shuffle(t)
        render 'index', layout: no

    get '/auth': ->
      redirect fb.getAuthorizeUrl
        client_id: appid
        redirect_uri: 'http://vote.2011f.pennapps.com/auth2'
        scope: 'email, user_education_history'

    get '/auth2': ->
      fb.getAccessToken appid,secret,@code,'http://vote.2011f.pennapps.com/auth2',
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
            teams.get @id,(team) ->
                team.votes++
                teams.save team
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
            teams.get @id,(team) ->
                team.votes--
                teams.save team
          users.save user, =>
            emit 'unvoted',
              id: @id
              client_id: client.id
            console.log user

    client '/index.js': ->
      connect()
      prompt_post = (name) ->
         window.fbAsyncInit = () ->
            FB.init({appId:'151280421549911',status: true,cookie: true, xfbml: true});
            FB.ui(publish, null);
            do ->
                e = document.createElement('script')
                e.async = true
                e.src = document.location.protocol +
                    '//connect.facebook.net/en_US/all.js'
                document.getElementById('fb-root').appendChild(e)

            publish =
              method: 'stream.publish'
              message: 'Just voted for '+name+' as my favorite PennApp - what\'s your\ s?'
              attachment:
                name: 'Vote for Best PennApp'
                caption: 'Vote before Midnight on Sunday'
                description: 'Over the last 40 hours, students built cool apps around data.  Now, it\'s time to choose a favorite.'
                href: 'http://pennapps.com/vote'
                media: [
                    type: 'image'
                    href: 'http://www.pennapps.com/vote'
                    src: 'http://www.pennapps.com/img/pennapps_new_logo.jpg'
                    ]
              action_links: [text: 'Vote Now', href: 'http://www.pennapps.com/vote']
              user_prompt_message: 'Wish your team luck'


      $().ready ->
        if window.location.hash != ''
          hash =
            if window.location.hash[0..0] == '#'
              window.location.hash[1...]
            else
              window.location.hash
          emit 'authorize',token: hash
          window.location.hash = ''
      window.vote_for = (team) ->
        emit 'vote', id: team
        node = $(".vote_#{team}")
        prompt_post node.data('name')
        node.attr('src','/tick_32.png').attr('onclick','').unbind('click').click do (team) -> () ->
            window.unvote(team)

      window.unvote = (team) ->
        emit 'unvote', id: team
        $(".vote_#{team}").attr('src','/checkbox_empty.png').unbind('click').click do (team) -> () ->
            window.vote_for(team)

      window.show_video = (url) -> $.colorbox
        transition: "fade"
        html: """<div><iframe class="youtube-player" type="text/html" width="640" height="385" src="http://www.youtube.com/embed/#{url}" frameborder="0">
</iframe></div>"""

      at voted: ->
        #console.log "Voted! #{@client_id} voted for #{@id}"
      at unvoted: ->
        #console.log "Unvoted! #{@client_id} voted for #{@id}"
      at authorized: ->
        $('.vote_for').show()
        for v in @votes
          $(".vote_#{v}").click()

    view index: ->
      doctype 5

      team_div = (team) ->
        div class: 'team span-one-third', ->
          a href: team.url, ->
            h3 team.name
          a onclick: "show_video('#{team.video}')", ->
            img
              width: 300
              height: 225
              src: "http://img.youtube.com/vi/#{team.video}/0.jpg"
              frameborder: 0
          div class: 'vote_for', style: 'float: right;display: none;', ->
            p "Vote"
            img
              src: 'checkbox_empty.png'
              name:'vote_tick'
              'data-name': team.name
              width: '40'
              height: '40px'
              onclick: "vote_for('#{team.id}')"
              class: "vote_#{team.id}"
          p class: 'description', ->
            team.description
          p class:'team_members', ->
            result = ""# I know, adding to a string is bad.
            result += member + " | " for member in team.team_members[...-1]
            result += team.team_members[-1..][0]
            result

      html ->
        head ->
          title 'PennApps Voting'
          script src: '/socket.io/socket.io.js'
          script src: '/zappa/jquery.js'
          script src: '/zappa/zappa.js'
          script src: '/jquery.colorbox-min.js'
          script src: 'http://connect.facebook.net/en_US/all.js'
          script src: '/index.js'

          link
            rel: 'stylesheet'
            href: "http://twitter.github.com/bootstrap/1.3.0/bootstrap.min.css"
        body ->
          div id: "fb-root"
          div class: "container", ->
            div class: "header", ->
              img src: "http://2011f.pennapps.com/storage/newest_logo.png"
              img src: "http://2011f.pennapps.com/storage/First-round-capital-logo.jpeg?__SQUARESPACE_CACHEVERSION=1315019808345"
              img src: 'pennua.jpg'
            div class: "explanation", ->
              p "Vote for your favorite applications and help decide the PennApps 2011 Student Choice Award Winner, sponsored by First Round Capital and in partnership with the Undergraduate Assembly."
              p "Feel free to vote for as many teams as you like."
            a href: "/auth", ->
              img src: 'fb.png'
            section id:'grid-system', ->
              for row in [0..@teams.length/3 + 1] #off by one error here?
                 div class:'row show-grid', ->
                  team_div t for t in @teams[row*3..row*3+2]
