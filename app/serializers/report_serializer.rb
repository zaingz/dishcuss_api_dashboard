class ReportSerializer < ActiveModel::Serializer
  attributes :id , :reason , :reporter

  def reporter
  	User.find(object.user.id).as_json(except: [:created_at, :updated_at , :password])
  end
end