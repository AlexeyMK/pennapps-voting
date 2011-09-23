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
        @winning_teams = (team for team in t when team.prestige > 0)
 
        shuffle = (input) ->
          swap  = (input, x,  y) -> [input[x], input[y]] = [input[y], input[x]]
          rand  = (x) -> Math.floor(Math.random() * x)
          permute = (input) -> swap(input, i, rand(i)) for i in [input.length-1..1]

          permute input
          return input

        @rest_teams = (team for team in shuffle(t) when team.prestige is 0)
        render 'index', layout: no

    get '/admin-jim-made-this-url': ->
      @teams_by_vote = {}
      users.all (err, users) =>
        incr = (key) => @teams_by_vote[key] = (@teams_by_vote[key] or 0) + 1
        for user in users
          incr(vote) for vote in user.votes
          
        render 'admin', layout: no
      #teams.all (err,t) =>
      #  @teams = t

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
      window.fbAsyncInit = () ->
        FB.init({appId:'151280421549911',status: true,cookie: true, xfbml: true})
        do ->
            e = document.createElement('script')
            e.async = true
            e.src = document.location.protocol +
                '//connect.facebook.net/en_US/all.js'
            document.getElementById('fb-root').appendChild(e)

      window.prompt_post = (name) ->
        publish =
          method: 'stream.publish'
          message: "Just voted for #{name} as my favorite PennApp - what\'s your\ s?" # this has become deprecated, which makes me sad
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
        FB.ui(publish, null)


      $().ready ->
        $('.video_colorbox').colorbox
          iframe: true
          innerWidth: 640
          innerHeight: 480

        if window.location.hash != ''
          hash =
            if window.location.hash[0..0] == '#'
              window.location.hash[1...]
            else
              window.location.hash
          emit 'authorize',token: hash
          window.location.hash = ''
          $('.loading').show()
      window.vote_for = (team) ->
        emit 'vote', id: team
        node = $(".vote_#{team}")
        #prompt_post node.data('name')
        #Facebook deprecated prefilling messages, so we have to be 
        #smarter about this. Any ideas?
        node.attr('src','/tick_32.png').attr('onclick','').unbind('click').click do (team) -> () ->
            window.unvote(team)

      window.unvote = (team) ->
        emit 'unvote', id: team
        $(".vote_#{team}").attr('src','/checkbox_empty.png').unbind('click').click do (team) -> () ->
            window.vote_for(team)

      at voted: ->
        #console.log "Voted! #{@client_id} voted for #{@id}"
      at unvoted: ->
        #console.log "Unvoted! #{@client_id} voted for #{@id}"
      at authorized: ->
        $('.vote_for').show()
        $('.auth').hide()
        for v in @votes
          $(".vote_#{v}").click()

    view index: ->
      doctype 5

      winning_team_div = (team) ->
        div class:'row show-grid', ->
          div class: 'winning_team span16', ->
            div class: 'winning_left', ->
              a {class: "video_colorbox cboxElement", href:"http://www.youtube.com/embed/#{team.video}?rel=0&wmode=transparent&autoplay=1"}, ->
                img
                  style: "background:url('http://img.youtube.com/vi/#{team.video}/0.jpg');"
                  width: '560'
                  height: '315'
                  src: 'play_overlay_large.png'
                  frameborder: 0
            div class: 'winning_right', ->
              a href: team.url, ->
                h2 team.name
                h3 team.prize #IE, "Winner of Student Choice Award"
              p class: 'description', ->
                team.description
              p class: 'app_link', -> a href: team.url, -> "View App" if team.url isnt ""
    
      team_div = (team) ->
        div class: 'team span-one-third', ->
          a href: team.url, ->
            h3 team.name
          a {class: "video_colorbox cboxElement", href:"http://www.youtube.com/embed/#{team.video}?rel=0&wmode=transparent&autoplay=1"}, ->
  #onclick: "show_video('#{team.video}')", ->
            img
              style: "background:url('http://src.sencha.io/260/195/http://img.youtube.com/vi/#{team.video}/0.jpg');"
              width: '260'
              height: '195'
              src: 'play_overlay.png'
              frameborder: 0
          div class: 'vote_for', style: 'float: right;display: none;', ->
            img
              src: 'checkbox_empty.png'
              name:'vote_tick'
              'data-name': team.name
              width: '40'
              height: '40'
              onclick: "vote_for('#{team.id}')"
              class: "vote_#{team.id}"
          p class: 'description', ->
            team.description
          p class: 'app_link', -> a href: team.url, -> "View App" if team.url isnt ""

      html ->
        head ->
          title 'PennApps Voting'
          link
            rel: 'stylesheet'
            href: "http://twitter.github.com/bootstrap/1.3.0/bootstrap.min.css"
          link
            rel: 'stylesheet'
            href:"style.css"
          #TEMP - hotlinked
          link
            rel: 'stylesheet'
            href: "colorbox.css"
          script src: '/socket.io/socket.io.js'
          script src: '/zappa/jquery.js'
          script src: '/jquery.colorbox-min.js'
          script src: '/zappa/zappa.js'
          script src: 'http://connect.facebook.net/en_US/all.js'
          script src: '/index.js'


        body ->
          div id: "fb-root"
          div class: "container", ->
            div class: "header", ->
              img src: "http://2011f.pennapps.com/storage/newest_logo.png"
              img src: "http://2011f.pennapps.com/storage/First-round-capital-logo.jpeg?__SQUARESPACE_CACHEVERSION=1315019808345"
              img src: 'pennua.jpg'
            div class: "explanation", ->
              p "Voting is closed.  <<br/> Winners for the PennApps 2011 Student Choice Award will be announced shortly."
              p "<small>Confused? <a href='http://2011f.pennapps.com/'>Learn about PennApps...</a></small>"
            section id:'grid-system', ->
              for winner in @winning_teams
                winning_team_div winner
              for row in [0..@rest_teams.length/3 + 1] #off by one error here?
                 div class:'row show-grid', ->
                  team_div t for t in @rest_teams[row*3..row*3+2]
    view admin: ->
      doctype 5
      team_row = (name, votes) ->
        tr ->
            td ->
                name
            td ->
                votes + ''
      html ->
        head ->
          title 'PennApps Admin'
          link
            rel: 'stylesheet'
            href:"style.css"
          link
            rel: 'stylesheet'
            href: "http://twitter.github.com/bootstrap/1.3.0/bootstrap.min.css"
        body ->
          table ->
            for name, vote of @teams_by_vote
              team_row name, vote
