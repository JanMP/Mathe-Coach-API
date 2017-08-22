{ Mongo } = require "meteor/mongo"
{ Meteor } = require "meteor/meteor"
import SimpleSchema from "simpl-schema"
_ = require "lodash"

ActivityGraphs = new Mongo.Collection "activityGraphs"
ActivityGraphs.schema = new SimpleSchema
  schoolClassId :
    type : String
    optional : true
  studentId :
    type : String
    optional : true
  days :
    type : Number
  selectedModules : [String]
ActivityGraphs.attachSchema ActivityGraphs.schema
exports.ActivityGraphs = ActivityGraphs

exports.insertActivityGraph = new ValidatedMethod
  name : "insertActivityGraph"
  validate : ActivityGraphs.schema.validator()
  run : (objectToInsert) ->
    {schoolClassId, studentId} = objectToInsert
    unless @userId
      throw new Meteor.Error "not logged-in"
    unless schoolClassId? or studentId?
      throw new Meteor.Error "no schoolClassId or studentId"
    ActivityGraphs.insert objectToInsert

exports.updateActivityGraph = new ValidatedMethod
  name : "updteActivityGraph"
  validate :
    new SimpleSchema
      id :
        type : String
      schoolClassId :
        type : String
        optional : true
      studentId :
        type : String
        optional : true
      days :
        type : Number
        optional : true
      selectedModules :
        type : Array
        optional : true
      "selectedModules.$" : String
    .validator()
  run : ( objectToUpdate ) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    id = objectToUpdate.id
    ActivityGraphs.update id,
      $set : _.omit objectToUpdate, "id"

exports.removeActivityGraph = new ValidatedMethod
  name : "removeActivityGraph"
  validate :
    new SimpleSchema
      id :
        type : String
    .validator()
  run : ({id}) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    ActivityGraphs.remove id
