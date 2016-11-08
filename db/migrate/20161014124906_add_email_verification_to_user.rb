class AddEmailVerificationToUser < ActiveRecord::Migration
  def change
  	add_column :users , :email_verification_code , :string
  end
end
