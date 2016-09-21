function signupsubmit() {
    var pass = document.getElementById('signup-password').value;
    var c_pass = document.getElementById('signup-cpassword').value;
    var name = document.getElementById('signup-name').value;
    var email = document.getElementById('signup-email').value;
    var username = document.getElementById('signup-username').value;

    var re = /[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}/igm;

    if (pass.length > 7 && pass == c_pass && re.test(email))
    {


    	localStorage.setItem("email", email);
    	localStorage.setItem("name", name);
    	localStorage.setItem("username", username);
    	localStorage.setItem("password", pass);

    	window.location.assign("signup_detail");
    	/*$.ajax({
	  		type: 'POST',
			
	  		url: serurl + 'user/signup',
	  		data:{
	  			user: {
					email: email,
					first_name: name,
					last_name: username,
					password: pass
				}

	  		},
	    	
		      	success: function (html) {
		      		console.log(html);
		      	},
		      	error: function() {
	                console.log("Error");
	            }
	   	});*/
    }else
    {
    	console.log("Lag Gyae");
    	document.getElementById('signup-password').value = "";
    	document.getElementById('signup-cpassword').value = "";
    	notify("Error occured while SigningUp" , "error");
    }
}


function signupprofile_1(){
	var email = localStorage.getItem("email");
	var name = localStorage.getItem("first_name");
	var usernam = localStorage.getItem("username");
	var password = localStorage.getItem("password");
	var countr = document.getElementById('coun').value;
	var city = document.getElementById('city').value;
	var date = document.getElementById('dat').value;
	var mont = document.getElementById('mont').value;
	var year = document.getElementById('year').value;
	var location = city + ", " + countr;
	var dob = date + "/"+ mont + "/" + year;
	console.log(email);
	console.log(usernam);
	console.log(dob);

	if(email != null){
		$.ajax({
	  		type: 'POST',
			
	  		url: serurl + 'user/signup',
	  		data:{
	  			user: {
					email: email,
					name: name,
					username: usernam,
					password: password,
					location: location,
					dob: dob,
					gender: 'male'
				}

	  		},
	    	
		      	success: function (html) {
		      		console.log(html);
		      		localStorage.clear();
		      		notify("Successfully SignedUp!" , "notice");
		      		window.location.assign("/signin");
		      	},
		      	error: function() {
	                console.log("Error");
	                notify("Error occured while SigningUp" , "error");
	            }
	   	});
	}else{
		window.location.assign("/signup");
	}
}