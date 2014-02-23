class Profile < ActiveRecord::Base
  has_and_belongs_to_many :posts, :uniq => true

  validates :uid, :uniqueness => true
  scope :tested, -> {where.not(ph_percent:nil)}
  scope :checked, -> {where.not(ph_manual:nil)}
  scope :promo_hunters, -> {where('ph_percent >= ?',TestConstants.ph_post_percent)}

  def link
    "https://www.facebook.com/profile.php?id="+self.uid
  end

  def self.token
    'CAAUgLojNQaoBAFSh9rs7snOhvuTCGQAWJzijIYQdw8MsBLpcbXCFQZCB5daBAxW3I1j4YZCZBI7Vjsnm20ztG3LP2iWBJHfhC1vCmXjRcbEHd657u1VFOqYiOnWpfZBa6MaZBjVPw0ZCb8BsSwBo5u9CXrI8UStqRidZCky64HMStZB737DgmrkG9UKV4tnJsI8ZD'
  end  

  def retest!    
    user_object = FbGraph::User.fetch(self.uid, :access_token => Profile.token)

    posts = user_object.posts  

    Post.transaction do 
      posts.each do |fb_post|      
          post = Post.create_or_find_same_from_fb_post( fb_post )
          self.posts<<post if post      
      end
    end

    bad_post_counter = self.posts.auto.promo.count
    if self.posts.any?
      self.ph_percent = bad_post_counter.to_f / self.posts.size.to_f
    else
      self.ph_percent = 0;
    end

    promo_hunter = (self.ph_percent>= TestConstants.ph_post_percent)
    self.right = (promo_hunter == self.ph_manual ) if self.ph_manual
    self.save
  end

  def type
    (self.ph_percent||=0) >= TestConstants.ph_post_percent ? "Призолов" : "Обычный"
  end

  def self.create_from_fb fb_user
    Profile.create(uid: fb_user.identifier, name:fb_user.name)
  end

  def self.right_percent
    per = Profile.checked.where(right:true).count.to_f/Profile.checked.count.to_f
    per = (per*100).round(1)
  end

  def color
    if self.right
      'green'
    else
      if self.right.nil?
        'grey'
      else
        'red'
      end
    end
  end
end
