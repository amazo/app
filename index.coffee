express = require 'express'
DynamoDBStore = require('connect-dynamodb') express

appCnf = require('../../app-config.json')

app = express()

module.exports = (secretKey, routes) ->
    app.configure ->
        app.set 'trust proxy', true
        app.use express.favicon(appCnf.path.favicon)
        app.use express.logger('dev')
        app.use express.bodyParser()
        app.use express.cookieParser()
        app.use express.session(
            store: new DynamoDBStore(AWSConfigPath: '../../aws-config.json', reapInterval: -1)
            cookie: {maxAge: 365 * 24 * 60 * 60 * 1000}
            secret: appCnf.secretKey)
        app.use app.router
        app.use express.static(path.join(__dirname, appCnf.path.public))

    app.configure 'development', ->
        app.use express.errorHandler()

    require('../../routes') app
    app
