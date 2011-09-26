mongo = require 'mongodb'
db = new mongo.Db('test', new mongo.Server("127.0.0.1", 27017, {}))
data = {}
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

db.open (err,db) ->
  db.dropDatabase(() -> false)
  teams.save
    id: 1
    votes: 0
    name: "bckchn.nl"
    url: "http://bckchn.nl"
    video: "eow70BRF2Z8"
    description: """bckchn.nl is a chat experiment. By definition, a backchannel is a discussion that takes place behind a subject or event. Bckchn.nl allows yo"""

  teams.save
    id: 2
    votes: 0
    name: "Bored?"
    url: ""
    video: "hVf6XW3uOpA"
    description: """Bored? is a socially aware boredom app that connects you to your interests and friends (declared by your social networks) by providing you w"""

  teams.save
    id: 3
    votes: 0
    name: "GetMeHome"
    url: ""
    video: "BfkeYGBkn4M"
    description: """GetMeHome is an android app that finds you the best way home. It uses the BingMaps API to give you the best results given cost and time."""

  teams.save
    id: 4
    votes: 0
    name: "Tick Talk"
    url: ""
    video: "W0qwP9USmMo"
    description: """"""

  teams.save
    id: 5
    votes: 0
    name: "PennMeet"
    url: ""
    video: "giKvpfhmsZ4"
    description: """Taking “the suck out of club listervs,” PennMeet allows users to quickly and wirelessly join, manage, and view groups through the cloud."""

  teams.save
    id: 6
    votes: 0
    name: "CrowdSource"
    url: ""
    video: "E3ic5RAZNb8"
    description: """"""

  teams.save
    id: 7
    votes: 0
    name: "Slam Whale"
    url: "http://slamwhale.com"
    video: "hgWH1doyfJE"
    description: """Creating poetry from tweets based on user input."""

  teams.save
    id: 8
    votes: 0
    name: "ClassGrapher"
    url: "http://coursegrapher.appspot.com"
    video: "1orvb9isiK4"
    description: """ClassGrapher displays average class and department ratings, such as course quality and difficulty, in an interactive, intuitive graph."""

  teams.save
    id: 9
    votes: 0
    name: "Guilt by Association"
    url: ""
    video: "_0BQvp2F-n8"
    description: """"""

  teams.save
    id: 10
    votes: 0
    name: "The Wiki Fund"
    url: "http://thewikifund.com"
    video: "2QbUKiEUsOE"
    description: """~ Investing 10 cents in your favorite project(e.g. PennApps)/charity ~
  ~ Investing for a better future ~"""

  teams.save
    id: 11
    votes: 0
    name: "uWave"
    url: "http://www.uwaved.com"
    video: "X5quQ_nnKFQ"
    description: """A microwave hacked to play YouTube videos while your food cooks, mention you on its Twitter account, and text you when your food is ready. """

  teams.save
    id: 12
    votes: 0
    name: "contxt"
    url: ""
    video: "FjdOfPxC3CY"
    description: """"""

  teams.save
    id: 13
    votes: 0
    name: "Penn Schedule Scrambler"
    url: ""
    video: ""
    description: """"""

  teams.save
    id: 14
    votes: 0
    name: "MacroNow"
    url: ""
    video: "G2UwATkfi04"
    description: """"""

  teams.save
    id: 15
    votes: 0
    name: "PicHacks"
    url: ""
    video: "e-DSrtP2gE0"
    description: """"""

  teams.save
    id: 16
    votes: 0
    name: "clickr"
    url: ""
    video: "l32VTefjipc"
    description: """"""

  teams.save
    id: 17
    votes: 0
    name: "Moody"
    url: ""
    video: "mxhbPI4eeXQ"
    description: """"""

  teams.save
    id: 18
    votes: 0
    name: "Beer Snob"
    url: "http://pm.kylehardgrave.com"
    video: "PFyGndCSurc"
    description: """The world of beer is big, but how are you supposed to explore it? Beer snob makes recommendations for brews based on your facebook profile!"""

  teams.save
    id: 19
    votes: 0
    name: "Let's Settle This"
    url: ""
    video: "pJd6RPgEC0A"
    description: """Settle disputes with your friends over trivial facts while making people put their money where their mouth is."""

  teams.save
    id: 20
    votes: 0
    name: "BuckIt"
    url: ""
    video: "1whBNaeBQYo"
    description: """"""

  teams.save
    id: 21
    votes: 0
    name: "mesht"
    url: ""
    video: "AjPKN8Tpeqw"
    description: """Did you ever feel like hanging out with friends, but didn't know who was near you to hang out with? Mesht is here to solve that problem fore"""

  teams.save
    id: 22
    votes: 0
    name: "Commit logs from last night"
    url: "http://www.commitlogsfromlastnight.com"
    video: "DLIf9dyxMxY"
    description: """A TFLM style aggregation of git commit logs, laden with profanity. """

  teams.save
    id: 23
    votes: 0
    name: "text20"
    url: "http://bit.ly/text-20"
    video: "u4xqiL3POjk"
    description: """Talk anonymously to Penn students with text20! After 20 texts, text "reveal" to exchange phone numbers, or "pass", to talk to someone else!"""

  teams.save
    id: 24
    votes: 0
    name: "Social+"
    url: ""
    video: "W2bHQ3jDA_k"
    description: """Social+ is a WP7 app that suggests good restaurants, movies and music events based on the user's current locaton & likes listed on facebook."""

  teams.save
    id: 25
    votes: 0
    name: "SmileTube"
    url: ""
    video: "MZQ7NrvvmUw"
    description: """"""

  teams.save
    id: 26
    votes: 0
    name: "RateMySchedule"
    url: ""
    video: "hHEujox1eTs"
    description: """"""

  teams.save
    id: 27
    votes: 0
    name: "TrendTV"
    url: ""
    video: "Pag9GT6iOLE"
    description: """"""

  teams.save
    id: 28
    votes: 0
    name: "Let's Play"
    url: "http://www.git.to/letsplay"
    video: "pt0L1NTYpFg"
    description: """Let's Play lets you text what sport & when you want to play it. Anyone with a sport & time that matches yours, will be notified."""

  teams.save
    id: 29
    votes: 0
    name: "Super Tumblr Search"
    url: "http://sameenjalal.com/Tumbling/pennapps/Tumbling/"
    video: "J3DENgGlLeg"
    description: """Tumblr's search capabilities are very limited; for example, searching for a term in the most recent post may result in a "No posts found".  """

  teams.save
    id: 30
    votes: 0
    name: "Mobile Casino"
    url: ""
    video: "qOVuV4xsrAg"
    description: """"""

  teams.save
    id: 31
    votes: 0
    name: "Prince of Thieves"
    url: ""
    video: "Gy-zWacslJw"
    description: """"""

  teams.save
    id: 32
    votes: 0
    name: "KaraokeJS, Team Trollgusta"
    url: "http://karaokejs.com"
    video: "ar8go7XKmwQ"
    description: """A battle karaoke game where the audience decides the winner along with real-time feedback and visualizations. Sing to Battle, Shake to Like"""

  teams.save
    id: 33
    votes: 0
    name: "Twalker"
    url: ""
    video: "80ICbkl0_q8"
    description: """"""

  teams.save
    id: 34
    votes: 0
    name: "staq.ly"
    url: ""
    video: "Tjg3h9LUXEE"
    description: """"""

  teams.save
    id: 35
    votes: 0
    name: "PennCoursePredictor"
    url: ""
    video: "7kx8B4_Fut0"
    description: """"""

  teams.save
    id: 36
    votes: 0
    name: "Konexin"
    url: ""
    video: "1R16Sn8N6Y0"
    description: """"""

  teams.save
    id: 37
    votes: 0
    name: "Dine 'n' Dash"
    url: ""
    video: "0nbXaFNjR9w"
    description: """"""

  teams.save
    id: 38
    votes: 0
    name: "Penn Course Planner"
    url: ""
    video: "RPA5JXrKTm0"
    description: """"""

  teams.save
    id: 39
    votes: 0
    name: "Let's Do Stuff"
    url: ""
    video: "8dzTKPjQkHY"
    description: """"""

  teams.save
    id: 40
    votes: 0
    name: "Social Ranking"
    url: ""
    video: "qryU6kLu9l8"
    description: """"""
  console.log "db reset"
