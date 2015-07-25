class UserFriendshipsController < ApplicationController

	before_filter :authenticate_user!
	respond_to :html, :json

	def index
		@user_friendships = current_user.user_friendships.all
		respond_with @user_friendships
	end

	def accept
		@user_friendship = current_user.user_friendships.find(params[:id])
		if @user_friendship.accept!
			flash[:success] = "You are now connected to #{@user_friendship.friend.first_name}"
		else
			flash[:error] = "Declined"
		end
		redirect_to user_friendships_path
	end

	def new
		if params[:friend_id]
			@friend = User.where(profile_name: params[:friend_id]).first
			raise ActiveRecord::RecordNotFound if @friend.nil?
			@user_friendship = current_user.user_friendships.new(friend: @friend)
		else
			flash[:error] = "Friend Request Failed"
		end
	rescue ActiveRecord::RecordNotFound
		render file: 'public/404', status: :not_found
	end

	  def create
	    if params[:user_friendship] && params[:user_friendship].has_key?(:friend_id)
	      @friend = User.where(profile_name: params[:user_friendship][:friend_id]).first
	      @user_friendship = UserFriendship.request(current_user, @friend)

	      respond_to do |format|
	      	if @user_friendship.new_record?
	      		format.html do
		        
		        	flash[:error] = "There was problem creating that friend request."
		        	redirect_to profile_path(@friend)
		        end
		    	format.json { render json: @user_friendship.to_json, status: :precondition_failed }
		    else
		      	format.html do
		      		flash[:notice] = "Friend request sent."
		      		redirect_to profile_path(@friend)
		      	end
		        format.json { render json: @user_friendship.to_json }
		    end		      
		  end
	    else
	      flash[:error] = "Friend required"
	      redirect_to root_path
	    end
	  end

	  # def edit
	  # 	@friend = User.where(profile_name: params[:id]).first
	  # 	@user_friendship = current_user.user_friendships.where(friend_id: @friend.id).first.decorate
	  # end

	def edit
		@user_friendship = current_user.user_friendships.find(params[:id]).decorate
		@friend = @user_friendship.friend
	end

	# def edit
	# 	@user_friendship = current_user.user_friendships.find(params[:id])
	# 	@friend = @user_friendship.friend
	# end

	def destroy
		@user_friendship = current_user.user_friendships.find(params[:id])
		if @user_friendship.destroy
			flash[:notice] = "Friend Deleted"
		end
		redirect_to user_friendships_path
	end


	def status_params
	  params.require(:user_friendship).permit(:user, :friend, :user_id, :friend_id)
	  @friend = @user_friendship.friend
	end

end

