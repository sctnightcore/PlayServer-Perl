package Core_Logic;
use strict;
use AntiCaptcha::Func_ac;
use PlayServer::Func_ps;
use Utils::Func_us;
use Utils::Var qw( $success_count $fail_count $report_count $report_count_success $report_count_fail );
use Data::Dumper;
use Win32::Console::ANSI;
use URI::Encode qw(uri_encode uri_decode);
$|++;

sub new {
	my ($class, %args) = @_;
	my $self = {};
	$self->{path} = $args{Path};
	$self->{antikey} = $args{Anticaptcha_key};
	$self->{gameID} = $args{GameID};
	$self->{ServerUrl} = $args{ServerUrl};
	$self->{ServerID} = $args{ServerID};
	$self->{debug} = $args{Debug};
	$self->{us} = Utils::Func_us->new( 
		Debug => $self->{debug}
	);
	$self->{ps} = PlayServer::Func_ps->new( 
		ServerUrl => $self->{ServerUrl}, 
		ServerID => $self->{ServerID}, 
		GameID => $self->{gameID}, 
		Debug => $self->{debug}
	);
	$self->{ac} = AntiCaptcha::Func_ac->new( 
		AntiKey => $self->{antikey}, 
		Debug => $self->{debug}
	);
	return bless $self, $class;
}


sub ac_getBalance {
	my ( $self ) = @_;
	$self->{ac}->get_Balance();
}

sub ac_getTask {
	my ( $self, $img ) = @_;
	$self->{ac}->get_Task($img);
}

sub ac_getAnswer {
	my ( $self, $taskid ) = @_;
	$self->{ac}->get_Answer($taskid);
}

sub ac_reportTaskid {
	my ( $self, $taskid ) = @_;
	$self->{ac}->report_Taskid($taskid);
}

sub ps_getImage {
	my ( $self ) = @_;
	$self->{ps}->get_Image();
}

sub ps_sendImage {
	my ( $self, $answer, $checksum ) = @_;
	$self->{ps}->send_Image($answer, $checksum);
}

sub us_updateTitle {
	my ( $self, $msg ) = @_;
	$self->{us}->update_Title($msg);
}

sub us_updateScore {
	my ( $self ) = @_;
	$self->{us}->update_score();
}

sub Main {
	my ( $self ) = @_;
	$self->us_updateTitle('PlayServer - Vote by sctnightcore')
	$self->us_updateScore();
	while (1) {
		my $balance = $self->ac_getBalance();
		my $image = $self->ps_getImage();
		if (defined($image)) {
			my $taskID = $self->ac_getTask($image->{base64});
			my $taskID_res = $self->get_Answer($taskID);
			my $res_ps = $self->ps_sendImage($taskID_res->{answer}, $image->{checksum});
			if (defined($res_ps)) {
				if ( $res_ps->{success} ) {
					$success_count += 1;
				} else {
					$fail_count += 1;
					my $report = $self->ac_reportTaskid($taskID);
					if ( $report->{status} eq 'success' && $report->{errorId} == 0 ) {
						$report_count += 1;
						$report_count_success += 1;
					} else {
						$report_count += 1;
						$report_count_fail += 1;
					}
				}
				sleep($res_ps->{'wait'});
				$self->us_updateScore();
			} else {
				sleep(5);
			}	
		} else {
			sleep(5);
		}
	}
}

1;