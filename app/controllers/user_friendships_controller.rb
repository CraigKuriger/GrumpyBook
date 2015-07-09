class UserFriendshipsController < ApplicationController


	before_filter :authenticate_user!

	def index
		@user_friendships = current_user.user_friendships.all
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
	    pp "X" * 40
	    pp @friend.id
	    @user_friendship = current_user.user_friendships.new(friend_id: @friend.id)
	    @user_friendship.save
	    flash[:notice] = "You're now friends with #{@friend.profile_name}"
	    redirect_to profile_path(@friend)
	  else
	    flash[:error] = "Friend Request Failed"
	    redirect_to root_path
	  end
	end

	# def create
	#   if params[:user_friendship] && params[:user_friendship].has_key?(:friend_id)
	#     @friend = User.where(profile_name: params[:friend_id]).first
	#     @user_friendship = current_user.user_friendships.new(friend: @friend)
	#     if @user_friendship.save
	#       flash[:success] = "Friendship created."
	#     else
	#       flash[:error] = "There was a problem."
	#     end
	#     redirect_to root_path
	#     # redirect_to profile_path(@friend)
	#   else
	#     flash[:error] = "Friend required"
	#     redirect_to root_path
	#   end
	# end



	def status_params
	  params.require(:user_friendship).permit(:user, :friend, :user_id, :friend_id)
	end

end

