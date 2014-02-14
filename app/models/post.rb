class Post < ActiveRecord::Base  
  has_and_belongs_to_many  :profiles

  scope :promo, -> {where("rate >= 1")}
  scope :usual, -> {where("rate < 1 ")}

  scope :auto, -> {where('manual_check IS NULL')}
  scope :manual, -> {where('manual_check IS NOT NULL')}

  validates :pid, :uniqueness => true
  before_save :check_link_lenght, :check_rate

  def fetch!
    fb_post = FbGraph::Post.fetch(self.pid,:access_token => Profile.token)
    self.text = fb_post.caption || fb_post.description || fb_post.message || fb_post.story 
    self.link = fb_post.link
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
    text = fb_post.caption || fb_post.description || fb_post.message || fb_post.story 
    params = {text: text, link: fb_post.link, pid: fb_post.identifier}
    same_post = Post.where(link: params[:link], text: params[:text]).first
    post = same_post || Post.create(params)
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
  private
  def check_link_lenght    
    self.link = self.link.first(255) if self.link?
  end

  def check_rate
    self.recalc_rate! if self.rate.nil?
  end  
end
