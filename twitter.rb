require 'launchy'
require 'oauth'
require 'yaml'
require 'json'
require 'pry'
CONSUMER_KEY = "UpwSh5XirW3hlNljRcF3xw"
CONSUMER_SECRET = "UgQhetUwdhDCus4nRphnPebMG4z1vmatEONmMFUEQ0"

CONSUMER = OAuth::Consumer.new(
  CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

class User

  attr_accessor :statuses

  def initialize
    @statuses = []


  end

  def statuses
    temp = []
    user_timeline.each do |tweet|
      temp <<  Status.new(EndUser::current_user, tweet["text"], tweet["created_at"])
    end
    @statuses = temp
  end

  def user_timeline
    # the access token class has methods `get` and `post` to make
    # requests in the same way as RestClient, except that these will be
    # authorized. The token takes care of the crypto for us :-)
    timeline = EndUser::access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json").body
    JSON.parse(timeline)
  end

end

class EndUser < User

  attr_reader :name, :timeline

  def initialize(name)

    super()
    @timeline = user_timeline
    @name = name
  end

  def inspect
    @name
  end

  def self.get_token(token_file)
    # We can serialize token to a file, so that future requests don't need
    # to be reauthorized.

    if File.exist?("#{token_file}.token")
      File.open("#{token_file}.token") { |f| YAML.load(f) }
    else
      access_token = request_access_token #ask
      File.open("#{token_file}.token", "w") { |f| YAML.dump(access_token, f) }

      access_token
    end
  end

  def self.access_token
    @@access_token
  end

  def self.current_user
    @@current_user
  end

  def self.login(username)
    @@access_token = get_token(username)
    @@current_user = EndUser.new(username)
  end

  def tweet(message)
    raise if message.length > 140
    #message = message.gsub(" ", "%20").gsub("'","%27").gsub("#", "%23")

    url = Addressable::URI.new(
          :scheme => "https",
          :host => "api.twitter.com",
          :path => "1.1/statuses/update.json",
          :query_values => {
            :status => message
          }).to_s
          p url
    EndUser::access_token.post(url)
  end

  def dm(username, message)
    #asdasdasdeasd12
    url = Addressable::URI.new(
          :scheme => "https",
          :host => "api.twitter.com",
          :path => "1.1/direct_messages/new.json",
          :query_values => {
            :text => message,
            :screen_name => username
          }).to_s
    EndUser::access_token.post(url)

  end

  def self.request_access_token
    # send user to twitter URL to authorize application
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"
    # launchy is a gem that opens a browser tab for us
    Launchy.open(authorize_url)

    # because we don't use a redirect URL; user will receive an "out of
    # band" verification code that the application may exchange for a
    # key; ask user to give it to us
    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp

    # ask the oauth library to give us an access token, which will allow
    # us to make requests on behalf of this user
    access_token = request_token.get_access_token(
        :oauth_verifier => oauth_verifier)
  end

end


class Status

  attr_reader :user, :message, :date

  def initialize(user, message, date)
    @user = user
    @message = message
    @date = date

  end

end

