		$("#dialog-ping").dialog({
			autoOpen: false,
			height: "auto",
			dialogClass: "dialog-noeffect ui-dialog-shadow",
			buttons: {
				Send: function() {
					var payload = {systemName: this.systemName, systemText: this.systemText, message: $('#ping-text').val() };
					const _this = this;
					$.ajax({
						url: "ping.php",
						type: "POST",
						data: payload,
						dataType: "text"
					}).done(function(data) {	$(_this).dialog("close"); })
					.fail(function(xhr, status, error) { console.log(status, error); });
				},
				Cancel: function() {
					$(this).dialog("close");
				},
			},
			open: function() {
				const wormholeID = $(this).data("id");
				const systemID = $(this).data("systemID");
				const wormhole = tripwire.client.wormholes[wormholeID];
				const fromSignature = wormhole ? tripwire.client.signatures[wormhole.initialID] : { name: null};
				
				this.systemName = tripwire.systems[systemID].name;
				this.systemText = this.systemName + (fromSignature.name !== null && fromSignature.name.length ? ' (' + fromSignature.name + ')' : '');
				
				$("#dialog-ping").dialog("option", "title", "Ping about "+this.systemText);
				$('#ping-text').val('');
				$('#ping-text').focus();
			}
		});