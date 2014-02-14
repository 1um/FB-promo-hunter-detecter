class ProfilesController < ApplicationController
  def index
    @profiles = Profile.all.order(:created_at)
  end

  def show
    @profile = Profile.find(params[:id])
    @profile.retest! if params[:retest]
    @promo_posts = @profile.posts.promo
    @usual_posts = @profile.posts.usual
  end

  def create    
    post = FbGraph::Post.fetch(params[:post_id],:access_token => Profile.token)
    likers = post.likes(limit:params[:limit].to_i)
    likers.each do |user|
      Profile.create(uid: user.identifier, name:user.name)      
    end
    redirect_to profiles_path
  end

  def update
    profile = Profile.find(params[:id])
    profile_params = params.require(:profile).permit(:ph_manual)
    profile_params[:ph_manual] = nil if profile_params[:ph_manual]=='on'
    profile.update(profile_params)
    profile.save
    redirect_to profiles_path
  end

  def test_index
    @profiles = Profile.checked.order(:created_at)
    @bw = TestConstants.bad_words
    @ph_post_percent = TestConstants.ph_post_percent
  end

  def test
    profile = Profile.find(params[:id])
    profile.retest!
    render json: {percent:profile.ph_percent, right:profile.right}
  end

  def update_test
    TestConstants.ph_post_percent = params[:ph_post_percent].to_f
    bw = params[:bw].each{|k,v| params[:bw][k] = v.to_f}
    TestConstants.bad_words = bw
    redirect_to test_index_profiles_path
  end

  def destoy_unmarked    
    Profile.where(ph_manual:nil).destroy_all
    redirect_to profiles_path
  end

  def retest_each
    Profile.checked.each(&:retest!)
    redirect_to test_index_profiles_path
  end
end
