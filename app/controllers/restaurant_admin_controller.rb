class RestaurantAdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :is_restaurant_owner
	layout "rest_admin"

	def index
		@restaurant = Restaurant.where(owner_id: @current_user.id)
	end

	def restaurant_detail
		if @current_user.role == 'admin'
			@restaurant = Restaurant.find(params[:id])
		else
			@restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:id])
		end
	end

	def check
		p params
		if params[:image].present?
			restaurant = Restaurant.new(name: params[:name] , typee: params[:typee] , location: params[:location] , opening_time: params[:opening_time].first , closing_time: params[:closing_time].first , per_head: params[:cost])
			restaurant.owner_id = @owner.id
			if restaurant.save
		        c_image = CoverImage.create(:image => params[:image][:image] , :restaurant_id => restaurant.id)
		        if params[:call_now].present?
		        	cal = CallNow.create(:number => params[:call_now] , :restaurant_id => restaurant.id)
		        end
				redirect_to :back , notice: 'Successfully Created'
			else
				redirect_to :back , notice: 'Unprocessable Entity'
			end
		else
			redirect_to :back , notice: 'Cover Image Missing'
		end
	end

	def update_cover_image
		p params
		if params[:image][:image].present?
			if @current_user.role == 'admin'
				rest = Restaurant.find(params[:id])
			else
				rest = Restaurant.where(owner_id: @current_user.id).find(params[:id])
			end
			if rest.cover_image.present?
				rest.cover_image.update(image: params[:image][:image])
			else
				cov  =CoverImage.create(image: params[:image][:image] , :restaurant_id => rest.id)
			end
		end
		redirect_to :back
	end

	def update_rest
		p params
		if @current_user.role == 'admin'
			res = Restaurant.find(params[:id])
		else
			res = Restaurant.where(owner_id: @current_user.id).find(params[:id])
		end
		res.update(rest_update_params)
		if params[:image].present?
			if res.cover_image.present?
				res.cover_image.update(params[:image][:image])
			else
				cov  =CoverImage.create(image: params[:image][:image] , :restaurant_id => res.id)
			end
		end
		redirect_to :back
	end

	def add_food_item
		p params
		if params[:name].present? && params[:fooditem][:price].present? && ( params[:section].present? || params[:menu_section].present? )
			cat_foo = false
			if @current_user.role == 'admin'
				restaurant = Restaurant.find(params[:restaurant_id])
			else
				restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:restaurant_id])
			end
			if restaurant.menu.nil?
				menur = Menu.create(name: 'Menu', summary: 'Menu', restaurant_id: restaurant.id)
			else
				menur = restaurant.menu
			end

			if params[:section].present?
				if menur.sections.where(title: params[:section]).count > 0
					sec = menur.sections.find_by_title(params[:section])
				else
					sec = Section.create(title: params[:section] , menu_id: menur.id)
				end
			else
				sec = menur.sections.find(params[:menu_section])
			end
			fooditem = FoodItem.create(name: params[:name], price: params[:fooditem][:price], section_id: sec.id)

			if params[:categories].present?
				params[:categories].each do |cat|
					fooditem.categories << Category.find(cat.to_i)
					cat_foo = true
				end
			end

			if params[:new_category].present?
				categ = Category.create(name: params[:new_category])
				fooditem.categories << categ
				cat_foo = true
			end

			if cat_foo == false
				if Category.where(name: 'Uncategorized').count > 0
					 cate_uncat = Category.find_by_name('Uncategorized')
				else
					cate_uncat = Category.create(name: 'Uncategorized')
				end
				fooditem.categories << cate_uncat
			end

			if params[:image].present?
				params[:image][:image].each do |img|
					photo = Photo.create(image: img , imageable_id: fooditem.id, imageable_type: 'FoodItem')
				end
			end
		end
		redirect_to :back
	end

	def food_items
		p params
		if @current_user.role == 'admin'
			@restaurant = Restaurant.find(params[:id])
		else
			@restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:id])
		end
		unless @restaurant.menu.nil?
			@food_items = @restaurant.menu.sections
		else
			sumr = @restaurant.name + ' menu'
			menu = Menu.create(name: 'Menu' , summary: sumr, restaurant_id: @restaurant.id)
			redirect_to request.original_url
		end
	end

	def update_fooditems
		p params
		food = FoodItem.find(params[:id])
		food.update(fooditem_params)
		if params[:section].present?
			menu = Menu.find(params[:menu_id])
			if menu.sections.where(title: params[:section]).count > 0
				sec = menu.sections.where(title: params[:section]).first
			else
				sec = Section.create(title: params[:section] , menu_id: params[:menu_id])
			end
			food.update(section_id: sec.id)
		end
		if params[:re_categories].present?
			params[:re_categories].each do |cat|
				food.categories.delete(cat.to_i)
			end
		end
		if params[:ad_categories].present?
			params[:ad_categories].each do |cat|
				if food.categories.where(id: cat.to_i).count < 1
					food.categories << Category.find(cat.to_i)
				end
			end
		end
		redirect_to :back
	end

	def delete_fooditem
		if @current_user.role == 'admin'
			restaurant = Restaurant.find(params[:restaurant_id])
		else
			restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:restaurant_id])
		end
		fooditem = FoodItem.find(params[:id])
		if fooditem.section.menu.restaurant.id == restaurant.id
			fooditem.destroy
		end
		redirect_to :back
	end

	def notifications
		if @current_user.role == 'admin'
			@restaurant = Restaurant.find(params[:id])
		else
			@restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:id])
		end
		@notifications = @restaurant.notifications
	end

	def seen_notification
		@notification = Notification.find(params[:id])
		unless @notification.seen
			@notification.update(seen: true)
		end
		redirect_to :back
	end

	def messages
		@restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:id])
		@message = Message.where(reciever_type: 'Restaurant').where(reciever_id: @restaurant.id)
	end

	def send_message
		mes = Message.create(body: params[:reply] , sender_id: params[:restaurant_id] , sender_type: 'Restaurant' , reciever_id: params[:user_id] , reciever_type: 'User')
		Message.find(params[:message_id]).update(status: 1)
		redirect_to :back
	end

	def gen_qr
		p params
		if params[:image].present? && params[:max_credit].present?
			qr = Qrcode.create(points: params[:points] , description: params[:description] , restaurant_id: params[:id] , max_credit: params[:max_credit])
			of = OfferImage.create(image: params[:image][:image] , qrcode_id: qr.id)
		end
		redirect_to :back
	end

	def qrcode
		if @current_user.role == 'admin'
			@restaurant = Restaurant.find(params[:id])
		else
			@restaurant = Restaurant.where(owner_id: @current_user.id).find(params[:id])
		end
		@qrcode = @restaurant.qrcodes.order(created_at: 'DESC')
	end

	def qrdetail
		@qr = Qrcode.find(params[:id])
		if @current_user.role == 'admin'
			@qrcode = @qr.credit_histories
		else
			@qrcode = Restaurant.where(owner_id: @current_user.id).find(@qr.restaurant.id).qrcodes.find(params[:id]).credit_histories
		end
	end

	def del_qrcode
		@qr = Qrcode.find(params[:id])
		if @current_user.role == 'admin'
			@qr.destroy
		else
			@qrcode = Restaurant.where(owner_id: @current_user.id).find(@qr.restaurant.id).qrcodes.find(params[:id])
			@qrcode.destroy
		end
		redirect_to :back
	end

	private
	def rest_update_params
		params.require(:restaurant).permit(:name , :opening_time , :closing_time , :location )
	end

	def fooditem_params
		params.require(:food_item).permit(:name , :price)
	end

end
