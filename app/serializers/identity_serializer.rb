class IdentitySerializer < ActiveModel::Serializer
  attributes :id , :provider , :url
end
