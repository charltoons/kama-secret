express = require('express')
http = require('http')
path = require('path')

app = express()

# all environments
app.set('port', process.env.PORT || 3000)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.json())
app.use(express.urlencoded())
app.use(express.methodOverride())
app.use(app.router)
app.use(express.static(path.join(__dirname, 'public')))

# development only
if ('development' == app.get('env'))
  app.use(express.errorHandler())

try
  config = require('./config.json')
catch
  console.log('No config.json, falling back to environment vars')
  config = process.env

AWS_ACCESS_KEY = config.AWS_ACCESS_KEY;
AWS_SECRET_KEY = config.AWS_SECRET_KEY;
S3_BUCKET = config.S3_BUCKET

app.get '/', (req, res, next)->
  res.render 'index'

app.get '/sign_s3', (req, res, next)->


http.createServer(app).listen app.get('port'), ->
  console.log('Express server listening on port ' + app.get('port'))
