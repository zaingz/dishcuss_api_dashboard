function notify(message , type){
	setTimeout( function() {
	// create the notification
	var notification = new NotificationFx({
		message : '<span class="icon icon-megaphone"></span><p>' + message + '</p>',
		layout : 'bar',
		effect : 'slidetop',
		type : type // notice, warning or error
	});

	// show the notification
	notification.show();

	}, 400 );
}
