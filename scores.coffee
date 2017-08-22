{ Mongo } = require "meteor/mongo"
{ Meteor } = require "meteor/meteor"
import SimpleSchema from "simpl-schema"

Scores = new Mongo.Collection "scores"
Scores.schema = new SimpleSchema
  userId :
    type : String
  category :
    type : String
  score :
    type : Number
    optional : true
Scores.attachSchema Scores.schema
exports.Scores = Scores

exports.incScore = new ValidatedMethod
  name : "incScore"
  validate :
    new SimpleSchema
      userId :
        type : String
      category :
        type : String
      score :
        type : Number
        optional : true
    .validator()
  run : ({userId, category, score}) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    unless @userId is userId
      throw new Meteor.Error "user not owner of score to change"
    score ?= 1
    Scores.update {userId, category}, {$inc : {score}}, {upsert : true}

exports.removeScore = new ValidatedMethod
  name : "removeScore"
  validate :
    new SimpleSchema
      userId :
        type : String
      category :
        type : String
    .validator()
  run : ({userId, category}) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    unless @userId is userId
      throw new Meteor.Error "user not owner of score to remove"
    Scores.deleteOne {userId, category}
