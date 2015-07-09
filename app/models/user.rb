class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :statuses
  has_many :user_friendships
  # has_many :friends, through: :user_friendships, conditions: {user_friendships: {state: 'accepted'}}

  has_many :friends, -> { where(user_friendships: { state: "accepted"}) }, through: :user_friendships

  # has_many :pending_user_friendships, class_name: 'UserFriendship', foreign_key: :user_id, conditions: {state: 'pending'}

  has_many :pending_user_friendships, -> { where user_friendships: { state: "pending"}}, through: :user_friendships

  # has_many :pending_friends, through: :pendiing_user_friendship, source: :friend

  has_many :pending_friends, -> { where user_friendships: { state: "pending" } }, through: :user_friendships, source: :friend

  def full_name
  	first_name + " " + last_name
  end

  def gravatar_url
    stripped_email = email.strip
    downcased_email = stripped_email.downcase
    hash = Digest::MD5.hexdigest(downcased_email)
    "http://gravatar.com/avatar/#{hash}"
  end

  def to_param
  	profile_name
  end
end


