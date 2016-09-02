class Identity < ActiveRecord::Base
	belongs_to :user

  def generate_token
    begin
      self.token = SecureRandom.hex.to_s
    end while self.class.exists?(token: token)
  end

end
