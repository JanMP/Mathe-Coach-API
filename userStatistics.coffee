# clientside collection only. Dont import on server

import { Mongo } from "meteor/mongo"
import { Meteor } from "meteor/meteor"

import { Submissions } from "/imports/api/submissions.coffee"

export UserStatistics = new Mongo.Collection "userStatistics"
