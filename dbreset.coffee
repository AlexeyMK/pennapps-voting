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
    id: 0
    votes: 0
    name: 'A Name'
    team_members: ['Jim Grandpre','Alexey Komissarouk']
    url: 'http://www.url.com'
    video: "BnDH-RXCptY"
    description: 'This is my app!'

  teams.save
    id: 1
    votes: 0
    name: 'A Name'
    team_members: ['Tim Lastname','Ayaka Firstname']
    url: 'http://www.link.com'
    video: "BnDH-RXCptY"
    description: 'This is their app!'

  teams.save
    id: 2
    votes: 0
    name: 'A Name'
    team_members: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
    url: 'http://www.website.com'
    video:"BnDH-RXCptY"
    description: 'Yet more application code produced by hacking hackery hacker hacks.'

  teams.save
    id: 3
    votes: 0
    name: 'A Name'
    team_members: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
    url: 'http://www.xkcd.com'
    video: "BnDH-RXCptY"
    description: 'Webcomics appropriately represented'

  teams.save
    id: 4
    votes: 0
    name: 'A Name'
    team_members: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
    url: 'http://www.alexeymk.com'
    video: "BnDH-RXCptY"
    description: 'This is a list of things which make me rather irate'

  teams.save
    id: 5
    votes: 0
    name: 'A Name'
    team_members: ['Four Score','And Seven','Years Ago']
    url: 'http://www.constitution.com'
    video: "BnDH-RXCptY"
    description: 'Governmental refrences tickle my fancy'

  teams.save
    id: 6
    votes: 0
    name: 'A Name'
    team_members: ['Presnted With','Much Elequonce','Product Sucked']
    url: 'http://www.whartoniteseekscodemonkey.com'
    video: "BnDH-RXCptY"
    description: 'Fantastically useless in every possible way.'

  teams.save
    id: 7
    votes: 0
    name: 'A Name'
    team_members: ['Jim Grandpre','Alexey Komissarouk']
    url: 'http://www.url.com'
    video: "BnDH-RXCptY"
    description: 'This is my app!'

  teams.save
    id: 8
    votes: 0
    name: 'A Name'
    team_members: ['Tim Lastname','Ayaka Firstname']
    url: 'http://www.link.com'
    video: "BnDH-RXCptY"
    description: 'This is their app!'

  teams.save
    id: 9
    votes: 0
    name: 'A Name'
    team_members: ['Ellen Yusti','Ellen Somebody','Forth Right','Questionable Content']
    url: 'http://www.website.com'
    video: "BnDH-RXCptY"
    description: 'Yet more application code produced by hacking hackery hacker hacks.'

  teams.save
    id: 10
    votes: 0
    name: 'A Name'
    team_members: ['Sunday Morning','Breakfast Cerial','Randal Munroe','Other Guy']
    url: 'http://www.xkcd.com'
    video: "BnDH-RXCptY"
    description: 'Webcomics appropriately represented'

  teams.save
    id: 11
    votes: 0
    name: 'A Name'
    team_members: ['Website Owners','Who Repeat','Poor Paridigns','Anger Alexey']
    url: 'http://www.alexeymk.com'
    video: "BnDH-RXCptY"
    description: 'This is a list of things which make me rather irate'

  teams.save
    id: 12
    votes: 0
    name: 'A Name'
    team_members: ['Four Score','And Seven','Years Ago']
    url: 'http://www.constitution.com'
    video: "BnDH-RXCptY"
    description: 'Governmental refrences tickle my fancy'

  teams.save
    id: 13
    votes: 0
    name: 'A Name'
    team_members: ['Presnted With','Much Elequonce','Product Sucked']
    url: 'http://www.whartoniteseekscodemonkey.com'
    video: "BnDH-RXCptY"
    description: 'Fantastically useless in every possible way.'

  console.log "db reset"
