require 'active_support/concern'
module NotificationHelper
	extend ActiveSupport::Concern
	def self.comment_notification(user , followed , followed_type , link)
		n = Notification.new(:notifier_id => user , :target_id => followed , :target_type => followed_type)
		useri = User.find(user)
		n.body = useri.username + ' commented on your ' + link
		n.save
	end

	def self.followed_notification(user , followed ,followed_type)
		n = Notification.new(:notifier_id => user , :target_id => followed , :target_type => followed_type)
		useri = User.find(user)
		n.body = useri.username + ' followed you!'
		n.save
	end

	def self.unfollowed_notification(user , followed ,followed_type)
		n = Notification.new(:notifier_id => user, :target_id => followed , :target_type => followed_type)
		useri = User.find(user)
		n.body = useri.username + ' unfollowed you!'
		n.save
	end

	def self.like_notification(notifier_id , target_id , target_type , link)
		n = Notification.new(:notifier_id => notifier_id, :target_id => target_id , :target_type => target_type)
		useri = User.find(notifier_id)
		n.body = useri.username + ' liked your ' + link
		n.save
	end

	def self.dislike_notification(notifier_id , target_id , target_type , link)
		n = Notification.new(:notifier_id => notifier_id, :target_id => target_id , :target_type => target_type)
		useri = User.find(notifier_id)
		n.body = useri.username + ' disliked your ' + link
		n.save
	end

	def self.post_notification(notifier_id , target_id)

	end

	def self.review_notification(notifier_id , target_id , target_type , link )
		n = Notification.new(:notifier_id => notifier_id, :target_id => target_id , :target_type => target_type)
		useri = User.find(notifier_id)
		n.body = useri.username + " reviewed on " + link
		n.save
	end

	def self.report_notification(notifier_id , target_id , target_type , link)
		case target_type
		when 'Comment'
			comment = Comment.find(target_id)
			commentable = comment.commentable_type
			if commentable == 'Post'
				target_id = comment.commentable.user_id
				target_type = 'User'
			else
				if commentable == 'Review'
					target_id = comment.commentable.reviewable_id
					target_type = comment.commentable.reviewable_type
				end
			end
		when 'Post'
			post = Post.find(target_id)
			target_id = post.user_id
			target_type = 'User'
		when 'FoodItem'
			food = FoodItem.find(target_id)
			target_id = food.menu.restaurant_id
			target_type = 'Restaurant'
		end
		n = Notification.new(:notifier_id => notifier_id, :target_id => target_id , :target_type => target_type)
		useri = User.find(notifier_id)
		n.body = useri.username + " reported your " + link
		n.save
	end

	def self.credit_notification(user_id , from)
		p 'Credit Notification'
		n = Notification.new( :target_id => user_id , :target_type => 'User')
		n.body = 'Credit points are added  in your account through '+ from
		n.save
	end

	def self.credit_history_notification(user_id , restaurant_id)
		n = Notification.new( :notifier_id =>  restaurant_id, :notifier_type => 'Restaurant', :target_id => user_id , :target_type => 'User')
		n.body = 'Credit points are claimed from your account.'
		n.save

		user = User.find(user_id)
		n = Notification.new( notifier_id: user_id , :target_id => restaurant_id , :target_type => 'Restaurant')
		n.body = user.username + ' claimed credit.'
		n.save

	end

end
