{ Mongo } = require "meteor/mongo"
{ Meteor } = require "meteor/meteor"
import SimpleSchema from "simpl-schema"
_ = require "lodash"

SchoolClasses = new Mongo.Collection "schoolclasses"
SchoolClasses.schema = new SimpleSchema
  _id :
    type : String
    optional : true
  name :
    type : String
  teacherId :
    type : String
    optional : true
SchoolClasses.attachSchema SchoolClasses.schema
exports.SchoolClasses = SchoolClasses

exports.saveSchoolClass = new ValidatedMethod
  name : "saveSchoolClass"
  validate : SchoolClasses.schema.validator()
  run : (d) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    unless Roles.userIsInRole @userId, "admin"
      throw new Meteor.Error "not admin"
    SchoolClasses.upsert _id : d._id,
      $set : _.omit d, "_id"

exports.deleteSchoolClass = new ValidatedMethod
  name : "deleteSchoolClass"
  validate :
    new SimpleSchema
      id :
        type : String
    .validator()
  run : ({ id }) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    unless Roles.userIsInRole @userId, "admin"
      throw new Meteor.Error "not admin"
    Meteor.call "removeAllStudentsFromClass", id : id
    SchoolClasses.remove _id : id

exports.removeAllStudentsFromClass = new ValidatedMethod
  name : "removeAllStudentsFromClass"
  validate :
    new SimpleSchema
      id :
        type : String
    .validator()
  run : ({ id }) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    unless Roles.userIsInRole @userId, "admin"
      throw new Meteor.Error "not admin"
    Meteor.users.update "schoolClassId" : id,
      $unset :
        "schoolClassId" : ""
