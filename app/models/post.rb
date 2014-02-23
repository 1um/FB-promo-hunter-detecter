class Post < ActiveRecord::Base  
  has_and_belongs_to_many  :profiles, :uniq => true

  scope :promo, -> {where("rate >= 1")}
  scope :usual, -> {where("rate < 1 ")}

  scope :auto, -> {where('manual_check IS NULL')}
  scope :manual, -> {where('manual_check IS NOT NULL')}

  validates :text, :uniqueness => true
  before_save :check_link_lenght, :check_rate

  def fetch (fb_post=nil)
    fb_post ||= FbGraph::Post.fetch(self.pid,:access_token => Profile.token)
    self.text = fb_post.name || fb_post.caption || fb_post.description || fb_post.message
    self.link = fb_post.link    
  end

  def fetch!
    self.fetch
    self.save
  end

  def recalc_rate!
    stemmer= Lingua::Stemmer.new(language: "ru")
    self.fetch! unless self.text
    clean_text = self.text.gsub(/[^a-zA-Zа-яА-Я’їієґЇІЄҐ]/,' ')
    clean_text = UnicodeUtils.downcase( clean_text ) 
    words = clean_text.split(' ')
    words.map!{|word| stemmer.stem(word)}
    words = words.to_set
    self.rate = 0
    TestConstants.bad_words.each do |black_word,val|
      self.rate+=val if words.include? black_word
    end   

    if self.promo? == self.manual_check
      self.manual_check = nil # algorithm become better!
    end

    self.save
    return self.rate
  end

  def promo?
    self.rate >= 1
  end

  def self.create_or_find_same_from_fb_post fb_post
    
    if fb_post.graph_object_id && fb_post.raw_attributes['status_type'] == "shared_story"
      begin
        fb_post = FbGraph::Post.fetch(fb_post.graph_object_id,:access_token => Profile.token)
      rescue => e
        #cant find original
      end
    end

    post = Post.new(pid: fb_post.identifier)
    post.fetch fb_post
    
    if(post.text)
      same_post = Post.where(text: post.text).first
      if same_post
        post = same_post 
      else
        post.save
      end
      return post
    else
      return nil
    end

  end

  def self.manual_percent
    per = self.manual.count.to_f / self.all.count.to_f
    per = (per*100).round(1)
  end

  def self.donwload_from_fb id, limit
    object = FbGraph::User.fetch(id, access_token: Profile.token)
    fb_posts = object.posts(limit: limit)
    fb_posts.each do |fb_post|
      self.create_or_find_same_from_fb_post(fb_post)
    end    
  end

  def fb_object
    FbGraph::Post.fetch(self.pid,:access_token => Profile.token)
  end

  def upload_likers count, fb_post=nil
    fb_post ||= self.fb_object
    
    if fb_post.graph_object_id
      begin
        fb_post = FbGraph::Post.fetch(fb_post.graph_object_id,:access_token => Profile.token)
      rescue => e
        
      end
    end
    
    likers = fb_post.likes(limit:count.to_i)
    likers.each do |fb_user|
      p = Profile.create_from_fb(fb_user)
      p.posts<<self      
    end
  end

  def promo_likers
    self.profiles.promo_hunters
  end

  private
  def check_link_lenght    
    self.link = self.link.first(255) if self.link?
  end

  def check_rate
    self.recalc_rate! if self.rate.nil?
  end  

end
