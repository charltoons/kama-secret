express = require('express')
http = require('http')
path = require('path')
crypto = require('crypto')

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

AWS_ACCESS_KEY = config.AWS_ACCESS_KEY
AWS_SECRET_KEY = config.AWS_SECRET_KEY
S3_BUCKET = config.S3_BUCKET

app.get '/', (req, res, next)->
  res.render 'index'

app.get '/sign_s3', (req, res, next)->
    object_name = req.query.s3_object_name
    mime_type = req.query.s3_object_type

    now = new Date()
    expires = Math.ceil((now.getTime() + 10000)/1000)
    amz_headers = "x-amz-acl:public-read"

    put_request = "PUT\n\n"+mime_type+"\n"+expires+"\n"+amz_headers+"\n/"+S3_BUCKET+"/"+object_name

    signature = crypto.createHmac('sha1', AWS_SECRET_KEY).update(put_request).digest('base64')
    signature = encodeURIComponent(signature.trim())
    signature = signature.replace('%2B','+')

    url = 'https://'+S3_BUCKET+'.s3.amazonaws.com/'+object_name

    credentials =
        signed_request: url+"?AWSAccessKeyId="+AWS_ACCESS_KEY+"&Expires="+expires+"&Signature="+signature
        url: url

    res.write(JSON.stringify(credentials));
    # res.json(credentials)
    res.end()


http.createServer(app).listen app.get('port'), ->
  console.log('Express server listening on port ' + app.get('port'))
