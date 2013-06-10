express = require 'express'
DynamoDBStore = require('connect-dynamodb') express

appCnf = require('../../app-config.json')

app = express()

module.exports = (secretKey, routes) ->
    app.configure ->
        app.set 'trust proxy', true
        app.use express.favicon(path.resolve(__dirname, '../../', appCnf.path.favicon))
        app.use express.logger('dev')
        app.use express.bodyParser()
        app.use express.cookieParser()
        if appCnf.session.memory
            app.use express.session()
            app.use (req, res, next) ->
                sid = req.get('X-Update-Session')
                if req.method is 'PUT' and sid?
                    cookie = req.sessionStore.sessions[sid].cookie
                    req.sessionStore.sessions[sid] = req.body
                    req.sessionStore.sessions[sid].cookie = cookie
                    res.send 200
                else
                    next()
        else
            app.use express.session(
                key: appCnf.session.key
                store: new DynamoDBStore(AWSConfigPath: path.resolve(__dirname, '../../', 'aws-config.json'), reapInterval: -1)
                cookie: {maxAge: 365 * 24 * 60 * 60 * 1000}
                secret: appCnf.secretKey)
        app.use app.router
        app.use express.static(path.resolve(__dirname, '../../', appCnf.path.public))

    app.configure 'development', ->
        app.use express.errorHandler()

    routes app
    app
