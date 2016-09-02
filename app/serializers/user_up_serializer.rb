class UserUpSerializer < ActiveModel::Serializer
  root :user
  attributes :id , :name, :username , :email , :location , :gender , :date_of_birth

  def date_of_birth
  	object.dob.present? ? object.dob.strftime("%d-%m-%Y") : ""
  end
end
