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
    stopwords = Array.new(File.foreach('app/assets/stopwords.txt').map { |line| line.split(' ') }).flatten
      

   
    @alltweets = @client.home_timeline('count' => 150).collect 
    @alltweets.each do |tweet|
      logger.debug tweet.text
      str = tweet.text.split.reject{ |x| stopwords.include?(x.downcase)}.reject{ |x| x[0] == "@" }
      logger.debug str
      str.each do |word|
        if h.key?(word)
          h[word] += 1
        elsif word[0] == "#"
          word.slice!(0)
          unless h.key?(word)
          h[word] = 2
          else
            h[word] +=2
          end
        else
          h[word] = 1
        end
      end
    end
    @top5 = h.sort_by {|k,v| -v}.first(5).select{|k,v| v >= 3}
    selectedtweets = {}
    
    @top5.each do |arr|
     @alltweets.each do |twt|
       twthash = {twt.text => twt.user.screen_name}
       selectedtweets = twthash.keep_if{ |k,v| k.include? arr[0] }
       unless selectedtweets.blank?
         unless arr[2].nil?
           arr[2].merge!(selectedtweets)
         else
           arr << selectedtweets
         end
       end
     end
      selectedtweets.clear
    end
  end
  
  def providebackground
    findhashtags
    stories = {}
    
    @top5.each do |arr|
      Google::Search::News.new do |search|
        stories.clear
        search.query = arr[0]
        search.language = :eng
        search.size = :small
      end.take(5).each { |item| stories.merge!({item.uri => item.title.html_safe}) }
      unless stories.blank?
        arr << stories.clone
      end
    end
  end
end