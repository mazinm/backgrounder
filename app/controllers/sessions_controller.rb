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
    h = {}
    gettweets
   
    @alltweets = @client.home_timeline('count' => 150).collect 
    @alltweets.each do |tweet|
      str = tweet.text
      str.split(" ").each do |word|
        if h.key?(word)
          h[word] += 1
        else 
          if word[0] == "#"  
          h[word] = 1
          end
        end
      end
    end
    @top5 = h.sort_by {|k,v| -v}.first(5)
    # .select{|k,v| v >= 3}
    logger.debug @top5
    selectedtweets = {}
    
    @top5.each do |arr|
     @alltweets.each do |twt|
       twthash = {twt.text => twt.user.screen_name}
       selectedtweets = twthash.keep_if{ |k,v| k.include? arr[0] }
       
       unless selectedtweets.blank?
         logger.debug selectedtweets
         unless arr[2].nil?
           arr[2].merge!(selectedtweets)
           logger.debug arr[2]
         else
           arr << selectedtweets
         end
         logger.debug arr
       end
       
     end
      selectedtweets.clear
    end
    logger.debug @top5
  end  
end