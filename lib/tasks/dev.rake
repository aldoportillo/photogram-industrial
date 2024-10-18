desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do

  p "Creating sample data"

  #Destroy Previous Data
  if Rails.env.development?
    FollowRequest.destroy_all
    Comment.destroy_all
    Like.destroy_all
    Photo.destroy_all
    User.destroy_all
  end

  #Generate Users
  user_list = ["alice", "bob", "carol", "dan", "eve", "craig", "mallory"]
  user_list.each do |name|
    User.create(
      email: "#{name}@example.com",
      password: "password",
      username: name,
      private: [true, false].sample,
    )
  end

  p "There are now #{User.count} users."

  #Generate Follow Requests
  users = User.all
  users.each do |first_user|
    users.each do |second_user|
      if rand < 0.75
        first_user.sent_follow_requests.create(
          recipient: second_user,
          status: FollowRequest.statuses.keys.sample
        )
      end

      if rand < 0.75
        second_user.sent_follow_requests.create(
          recipient: first_user,
          status: FollowRequest.statuses.keys.sample
        )
      end
    end
  end

  p "There are now #{FollowRequest.count} follow requests."

  # Generate Photos

  users.each do |user|
    rand(15).times do
      photo = user.own_photos.create(
        caption: Faker::TvShows::Suits.quote,
        image: "https://robohash.org/#{rand(9999)}"
      )

      # Generate Likes

      user.followers.each do |follower|
        if rand < 0.5
          photo.fans << follower
        end

         # Generate Comments
        if rand < 0.25
          photo.comments.create(
            body: Faker::TvShows::Suits.quote,
            author: follower
          )
        end
      end
    end
  end

  p "There are now #{Photo.count} photos."
  p "There are now #{Like.count} likes."
  p "There are now #{Comment.count} comments."

end
