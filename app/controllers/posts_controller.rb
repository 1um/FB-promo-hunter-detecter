class PostsController < ApplicationController

  def index
    posts = params[:manual] ? Post.manual : Post.auto        
    @promo_posts = posts.promo.order("rate ")
    @usual_posts = posts.usual.order("rate DESC")    
  end

  def manual_type
    post = Post.find(params[:id])
    post.update(manual_check: params[:type])
    post.save
    respond_to do |format|
      format.html { redirect_to action: 'index' }
      format.js {render nothing: true}
    end
    
  end

  def recalc_rate_all
    Post.all.each(&:recalc_rate!)
    redirect_to action: 'index'
  end

  def create
    Post.donwload_from_fb(params[:id], params[:limit])
    redirect_to action: 'index'
  end

  def likers
    @post = Post.find(params[:id])
    @profiles = @post.profiles.order(:created_at)    
  end

  def add_likers
    @post = Post.find(params[:id])
    @post.upload_likers(params[:count].to_i)
    redirect_to action: 'likers'
  end

  def destroy
    Post.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to :back  }
      format.js {render nothing: true}
    end
  end

end
