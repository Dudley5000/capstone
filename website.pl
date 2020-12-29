#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

get '/:pct' => sub($c) {
	my $pct = $c->param( 'pct' );
	$c->render( json => { msg => 'Error: Non-numeric input detected' } )
		unless $pct =~ /^\d+$/;

	chdir 'python';
	my $cmd    = join( ' ', ( 'python3', 'stock_prediction.py', $pct ) );
	my $retval = `$cmd`;
	$c->render( json => { ret => $retval, cmd => $cmd } );
};

get '/' => 'main';

app->start;

__DATA__

@@ main.html.ep
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
		<meta name="description" content="">
		<meta name="author" content="">
		<title>Stock Prediction Tool</title>
		<!-- <link rel="icon" href="/docs/4.0/assets/img/favicons/favicon.ico"> -->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
		<link href="website.css" rel="stylesheet">
	</head>
	<body>
		<div class="container">
			<div class="row">
				<div class="col">
					<h1>Stock Market Profitable Tickers Selection Tool</h1>
				</div>
			</div>
			<div class="row">
				<div class="col-12">
					<h2>Drag the slider and click the button to list all stocks predicted to beat the S&P by <span id="beat_pct">0</span> percent.</h2>
				</div>
				<div class="col-10">
					<input type="range" min="0" max="60" value="0" class="slider" id="myRange">
				</div>
				<div class="col-2">
					<button id="btnSubmit" type="button" class="btn btn-primary">Go</button>
				</div>
			</div>
			<div class="row">
				<div class="col">
					<div id="output">
						<div id="spinny" class="spinner-border d-none"></div>
					</div>
				</div>
			</div>
		</div>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
		<script type="text/javascript">
			$(function() {
				$('#myRange').on('input', function(){
					$('#beat_pct').text(this.value);
					// console.log('Value: ' + this.value)
				});
				$('#btnSubmit').on('click', function(){
					if (!$("#spinny").length){
						$('#output').html('<div id="spinny" class="spinner-border d-none"></div>');
					}
					$(".spinner-border").toggleClass('d-none');
					$.ajax({
					url: $('#myRange').val(),
					success: function(data, status, jqXHR){
						$(".spinner-border").toggleClass('d-none');
						var ret = JSON.parse(data.ret);
						console.warn(ret);
						var str;
						if (ret.msg){
							str = ret.msg;
						} else {
							var ct = ret.stocks.length;
							var max_row_count = 20;
							var rows = Math.floor(ct / max_row_count);
							if (rows){
								for (var i = 1; i <= rows; i++){
									ret.stocks.splice(max_row_count * i, 0, '\n');
								}
							}
							str = 'Stocks: ' + ret.stocks.join(', ').replace(/ \n, /g, ' \n        ') + '\n';
							str += '\nAccuracy Score: ' + ret.accuracy_score + '\n';
							str += '\nConfusion Matrix: ' + JSON.stringify(ret.confusion_matrix) + '\n\n';
							str += '                Classification Report\n';
							str += '                ---------------------\n\n';
							str += ret.classification_report;
						}
					$('#output').html('<pre>'+str+'</pre>');
				},
				dataType: 'json'
				});
			});
		});
	</script>
</body>
</html>
