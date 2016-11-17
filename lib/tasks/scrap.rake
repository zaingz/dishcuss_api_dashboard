namespace :scrap do
  desc "TODO"
  task panda: :environment do
  	require 'rubygems' 
	require 'nokogiri' 
	require 'open-uri'

	#open("/home/tayyab/Downloads/Tayyab/Office/Projects/foodpanda scrap/Order online food delivery from Lahore's best restaurants.html")
	r = open("/home/holygon/panda/foodpanda scrap/Order online food delivery from Lahore's best restaurants.html")
	rest_tem = Nokogiri::HTML(r)
	count = 1
	rest_tem.css('.vendor__inner').each do |es|
		if count < 100
			t_img = es.css('.vendor__image img').attr('src').to_s
			img = "https://asia-public.foodpanda.com/dynamic/production/pk/images/vendors/" + t_img.split('/').last.gsub('(1)','')
			#unless img.include? "no_pic_logo"
			#	File.open(es['href'].to_s.split('/').last + '.png', 'wb') do |file|
			#	  if open(img)
			#	  	file << open(img).read
			#	  end
			#	end
			#end

			rest_name = es['href'].to_s.split('/').last
			if File.exist?('public/restaurant/' + rest_name + '.png')
				cdf = File.open('public/restaurant/' + rest_name + '.png')
				unless Restaurant.find_by_name(rest_name)
					if r = Restaurant.create(name: rest_name , typee: 'Restaurant' , location: 'Lahore, Punjab, Pakistan' , opening_time: '12:00 pm' , closing_time: '12:00 am' , approved: true , per_head: 0 , owner_id: 1)
						CoverImage.create(:image => cdf , :restaurant_id => r.id)

						p 'Restaurant Created'

						if meni = Menu.create(name: 'Menu', summary: 'Menu', restaurant_id: r.id)

							p 'Menu Created'

							c = open(es['href'])
							doc = Nokogiri::HTML(c)
							menu = doc.css('.menu__category')

							menu.each do |men|
								p 'Section'
								secti = men.css('.menu__category__title').text
								sec_ns = secti.to_s.strip

								#p 'Checking Section'
								#if men.sections.where(title: sec_ns).count > 0
								#	p 'Section Found'
								#	sec = men.sections.find_by_title(params[section: sec_ns])
								#else
								#	p 'Section Created'
								#	sec = Section.create(title: sec_ns , menu_id: meni.id)
								#end

								p 'Section Created'
								sec = Section.create(title: sec_ns , menu_id: meni.id)

								men.css(".menu-item").each do |sha| 
									cate = sha.css('.menu-item__title').text
									sha.css('.js-fire-click-tracking-event').each do |var|
										ser = var.css('.menu-item__variation__title').text
										pr = var.css('.menu-item__variation__price__before-discount').text
										if pr.length < 1
											pr = var.css('.menu-item__variation__price').text
										end
										p 'FoodItem Created'
										fd = FoodItem.create(name: cate.to_s.strip , price: pr.gsub(/[^0-9]/, "") , section_id: sec.id)

										p 'Category Created'
										if cato = Category.find_by_name(sec_ns)
											fd.categories << cato
										else
											c_new = Category.create(name: sec_ns)
											fd.categories << c_new
										end
									end
								end
							end
						end
					end
				end
			else
				p "Not Exists"
			end
		end
		count = count + 1
	end
  end

end
