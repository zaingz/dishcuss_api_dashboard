class NotificationSerializer < ActiveModel::Serializer
  attributes :id , :body , :notifier , :seen

  def notifier
	if object.notifier_id.present?
  		User.find(object.notifier_id).as_json(except:  [:created_at, :updated_at , :password , :role , :referal_code , :followees_count , :followers_count , :likees_count ] )
	end
  end
end
