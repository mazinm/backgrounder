class SessionsController < ApplicationController
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
  
  def gettweets
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.access_token = current_user.token
      config.access_token_secret = current_user.secret
     end
  end
  
  def findhashtags
    @h = {}
    gettweets
   
    @client.home_timeline.collect do |tweet|
      
      str = tweet.text
      str.split(" ").each do |word|
        if @h.key?(word)
          @h[word] += 1
        else 
          if word[0] == "#"  
          @h[word] = 1
        end
      end
      end
      @h.sort_by {|k,v| v}
    end
  end
end