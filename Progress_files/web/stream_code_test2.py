# https://stackoverflow.com/questions/27430754/using-tweepy-to-listen-to-stream-and-search-for-tweets-how-to-stop-previous-sea
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
from config_gab import CONSUMER_KEY, CONSUMER_SECRET
from config_gab import ACCESS_TOKEN, ACCESS_TOKEN_SECRET
from info import data

from flask import Flask, Response, stream_with_context, redirect, url_for, flash, request
from flask import render_template, jsonify

# OAuth process
auth = OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)

# create application
app = Flask(__name__)
prev_list = list()

@app.route('/search',methods=['POST'])
# gets search-keyword and starts stream
def streamTweets():
    search_term = request.form['tweet']
    search_term_hashtag = '#' + search_term
    listener = StreamListener()
    # stream object uses listener we instantiated above to listen for data
    twitterStream = Stream(auth, listener())
    twitterStream.filter(track=[search_term_hashtag])
    
    redirect('/stream') # execute '/stream' sse
    return render_template('index.html')

@app.route('/stream')
def stream():
  # we will use Pub/Sub process to send real-time tweets to client
  def event_stream():
    # instantiate pubsub
    pubsub = red.pubsub()
    # subscribe to tweet_stream channel
    pubsub.subscribe('tweet_stream')
    # initiate server-sent events on messages pushed to channel
    for message in pubsub.listen():
      yield 'data: %s\n\n' % message['data']
      # redirect('/stream/')
  return Response(stream_with_context(event_stream()), mimetype="text/event-stream")

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
    
