class Profile < ActiveRecord::Base
  validates :uid, :uniqueness => true  
  scope :checked, where.not(ph_manual:nil)

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
      all_captions = feed.map(&:caption)
      bad_post_counter = 0
      all_captions.each do |text|
        if text    
          clean_text = text.gsub(/[^а-яА-Я]/,' ')
          clean_text = UnicodeUtils.downcase( clean_text ) 
          words = clean_text.split(' ')
          words.map!{|word| stemmer.stem(word)}
          words = words.to_set    
          rate = 0
          TestConstants.bad_words.each do |black_word,val|
            rate+=val if words.include? black_word
          end          
          bad_post_counter+=1 if rate>=1
        end
      end      
      self.ph_percent = bad_post_counter.to_f / all_captions.size.to_f
      promo_hunter = (self.ph_percent>= TestConstants.ph_post_percent)
      self.right = (promo_hunter == self.ph_manual )
      self.save
    end
  end

  def self.right_percent
    per = Profile.checked.where(right:true).count.to_f/Profile.checked.count.to_f
    per = (per*100).round(1)
  end

end
