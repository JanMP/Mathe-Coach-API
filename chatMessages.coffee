{ Mongo } = require "meteor/mongo"
{ Meteor } = require "meteor/meteor"
import SimpleSchema from "simpl-schema"

ChatMessages = new Mongo.Collection "chatMessages"
ChatMessages.schema = new SimpleSchema
  senderId :
    type : String
  receiverId :
    type : String
  dateSent :
    type : Date
  text :
    type : String
  read :
    type : Boolean
ChatMessages.attachSchema ChatMessages.schema
exports.ChatMessages = ChatMessages

ChatMessages.helpers
  sender : ->
    Meteor.users.findOne _id : @senderId()
  senderName : ->
    @sender().fullName()
  avatar : ->
    @sender().avatar()
  receiverName : ->
    @sender().fullName()

exports.sendMessage = new ValidatedMethod
  name : "sendMessage"
  validate :
    ChatMessages.schema
    .pick(["receiverId", "dateSent", "text"])
    .validator()
  run : ({receiverId, dateSent, text}) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    ChatMessages.insert
      senderId : @userId
      receiverId : receiverId
      dateSent : dateSent
      text : text
      read : false

exports.markAsRead = new ValidatedMethod
  name : "markAsRead"
  validate :
    new SimpleSchema
      id :
        type : String
    .validator()
  run : ({ id }) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    message = ChatMessages.findOne _id : id
    unless message?
      throw new Meteor.Error "no message with id"
    unless message?.receiverId is @userId
      throw new Meteor.Error "user is not receiver"
    ChatMessages.update _id : id,
      $set :
        read : true

exports.removeMessage = new ValidatedMethod
  name : "removeMessage"
  validate :
    new SimpleSchema
      id :
        type : String
    .validator()
  run : ({ id }) ->
    unless @userId
      throw new Meteor.Error "not logged-in"
    message = ChatMessages.findOne _id : id
    unless message?
      throw new Meteor.Error "no message with id"
    unless message?.receiverId is @userId or
      message?.senderId is @userId or
      Roles.userIsInRole @userId, "admin"
        throw new Meteor.Error "user is not authorized"
    ChatMessages.remove _id : id
