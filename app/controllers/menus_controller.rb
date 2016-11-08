class MenusController < ApplicationController
	before_filter :restrict_access
	before_filter :is_restaurant_owner
	def create
		p params
		restaurant = Restaurant.approved.where(owner_id: @owner.id).where(id: params[:menu][:restaurant_id])
		if restaurant.owner == @current_user
			if restaurant.menu.present?
				render json: {'message' => 'Menu is already present'} , status: :bad_request
			else
					menu = Menu.new menu_params
					menu.restaurant_id = restaurant.id
					if menu.save
						render json: menu, status: :created
					else
						render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
					end
			end
		else
			render json: {'message' => 'Restaurant doesnot belongs to you!'} , status: :bad_request
		end
	end

	def update
		if restaurant = Restaurant.where(owner_id: @owner.id).where(id: params[:id])
			 menuu = restaurant.menu.update_attributes(menu_update_params)
			 render json: {'message' => 'Successfully Updated!'}, status: :ok
		end
	end

	private
	def menu_params
		params.require(:menu).permit(:restaurant_id , :name , :summary , food_items_attributes: [:restaurant_id , :name , :price , :image , category: [:name]])
	end
	def menu_update_params
		params.require(:menu).permit( :name , :summary)
	end
end
