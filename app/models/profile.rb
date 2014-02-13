class Profile < ActiveRecord::Base
  validates :uid, :uniqueness => true  
  scope :checked, -> {where.not(ph_manual:nil)}
  attr_accessor :posts
  
  def link
    "https://www.facebook.com/profile.php?id="+self.uid
  end

  def self.token
    'CAAUgLojNQaoBAFSh9rs7snOhvuTCGQAWJzijIYQdw8MsBLpcbXCFQZCB5daBAxW3I1j4YZCZBI7Vjsnm20ztG3LP2iWBJHfhC1vCmXjRcbEHd657u1VFOqYiOnWpfZBa6MaZBjVPw0ZCb8BsSwBo5u9CXrI8UStqRidZCky64HMStZB737DgmrkG9UKV4tnJsI8ZD'
  end  

  def retest!
    stemmer= Lingua::Stemmer.new(language: "ru")
    user_object = FbGraph::User.fetch(self.uid, :access_token => Profile.token)  
    feed = user_object.feed
    unless feed.empty?
      self.posts = {}
      bad_post_counter = 0
      feed.each do |post|         
        text = post.caption
        if text    
          clean_text = text.gsub(/[^a-zA-Zа-яА-Я’їієґЇІЄҐ]/,' ')
          clean_text = UnicodeUtils.downcase( clean_text ) 
          words = clean_text.split(' ')
          words.map!{|word| stemmer.stem(word)}
          words = words.to_set
          rate = 0
          TestConstants.bad_words.each do |black_word,val|
            rate+=val if words.include? black_word
          end
          stemmed_str = words.inject(""){|str,elem|str+=elem+", "}
          self.posts[post.identifier]={text: text,link:post.link,rate: rate, stemmed: stemmed_str}
          bad_post_counter+=1 if rate>=1
        else
          self.posts[post.identifier] = {link:post.link}
        end
      end      
      self.ph_percent = bad_post_counter.to_f / feed.size.to_f
      promo_hunter = (self.ph_percent>= TestConstants.ph_post_percent)
      self.right = (promo_hunter == self.ph_manual )
      self.save
    end
  end

  def type
    self.ph_percent||0 >= TestConstants.ph_post_percent ? "Призолов" : "Обычный"
  end
  def self.right_percent
    per = Profile.checked.where(right:true).count.to_f/Profile.checked.count.to_f
    per = (per*100).round(1)
  end

end
