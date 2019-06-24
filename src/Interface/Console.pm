package Interface::Console;
use strict;
no strict 'refs';
use Var qw($quit);
use Time::HiRes qw(time usleep);
use Win32::Console::ANSI;
use Text::Wrap;
use Win32::Console;
our %fgcolors;
our %bgcolors;
sub new {
	my $class = shift;
	my $self = {
		input_list => [],
		last_line_end => 1,
		input_lines => [],
		input_offset => 0,
		input_part => '',
		codepage => 874
	};
	bless $self, $class;

	$self->{out_con} = new Win32::Console(STD_OUTPUT_HANDLE()) || die "Could not init output Console: $!\n";
	$self->{in_con} = new Win32::Console(STD_INPUT_HANDLE()) || die "Could not init input Console: $!\n";
	$self->setWinDim();
	
	$self->{out_con}->Cursor(0, $self->{in_line});
	$self->{out_con}->OutputCP($self->{codepage});
	$self->{in_con}->InputCP($self->{codepage});
	return $self;
}


sub getInput {
	my $self = shift;
	my $timeout = shift;
	$self->readEvents();
	my $msg;
	if ($timeout == 1) {
		until (defined $msg) {
			$self->readEvents();
			usleep(10000);
			if (@{$self->{input_lines}}) {
				$msg = shift @{$self->{input_lines}};
			}
			last if ($quit);
		}
	} elsif ($timeout > 0) {
		my $end = time + $timeout;
		until ($end < time || defined $msg) {
			$self->readEvents();
			usleep(10000);
			if (@{$self->{input_lines}}) {
				$msg = shift @{$self->{input_lines}};
			}
			last if ($quit);
		}
	} else {
		if (@{$self->{input_lines}}) {
			$msg = shift @{$self->{input_lines}};
		}
	}
	undef $msg if (defined $msg && $msg eq '');

	return $msg;
}

sub writeoutput  {
	my $self = shift;
	my $message = shift;
	my $tag = shift;
	#wrap the text
	local($Text::Wrap::columns) = $self->{right} - $self->{left} + 1;
	my ($endspace) = $message =~ /(\s*)$/; #Save trailing whitespace: wrap kills spaces near wraps, especialy at the end of stings, so "\n" becomes "", not what we want
	$message = wrap('', '', $message);
	$message =~ s/\s*$/$endspace/; #restore the whitespace
	
	my $lines = $message =~ s/\r?\n/\n/g; #fastest? way to count newlines
	
	#this paragraph is all about handleing lines that don't end in a newline. I have no clue how it works, even though I wrote it, but it does. =)
	$lines++ if (!$lines && $self->{last_line_end});
	if ($lines && !$self->{last_line_end}) {
		$lines--;
		$self->{out_line}--;
	} elsif (!$self->{last_line_end}) {
		$self->{out_line}--;
	}
	$self->{last_line_end} = ($message =~ /\n$/) ? 1 : 0;

	my $ret = $self->{out_con}->Scroll(
		$self->{left}, 0, $self->{right}, $self->{out_bot},
		0, 0-$lines, ord(' '), $ATTR_NORMAL, 
		$self->{left}, 0, $self->{right}, $self->{out_bot}
	);

	my ($ocx, $ocy) = $self->{out_con}->Cursor();
	$self->{out_con}->Cursor($self->{out_col}, $self->{out_line} - $lines);

	if (defined $tag) {
		$self->{out_con}->Attr($fgcolors{$tag});
		$self->{out_con}->Write($message);
		$self->{out_con}->Attr($bgcolors{reset});
	} else {
		$self->{out_con}->Write($message);
	}

	($self->{out_col}, $self->{out_line}) = $self->{out_con}->Cursor();
	$self->{out_line} -= $self->{last_line_end} - 1;
	$self->{out_con}->Cursor($ocx, $ocy);
}

sub setWinDim {
	my $self = shift;
	my($wLeft, $wTop, $wRight, $wBottom) = $self->{out_con}->Window() or die "Can't find initial dimentions for the output window\n";
	my($bCol, $bRow) = $self->{out_con}->Size() or die "Can't find dimentions for the output buffer\n";
	$self->{out_con}->Window(1, $wLeft, $bRow - $wBottom - 1, $wRight, $bRow - 1);# or die "Can't set dimentions for the output window\n";
	@{$self}{qw(left out_top right in_line)} = $self->{out_con}->Window() or die "Can't find new dimentions for the output window\n";
	$self->{out_bot} = $self->{in_line} - 1; #one line above the input line
	$self->{out_line} = $self->{in_line};
	$self->{out_col} = $self->{in_pos} = $self->{left};
}

sub readEvents {
	my $self = shift;
#	local($|) = 1;
	while ($self->{in_con}->GetEvents()) {
		my @event = $self->{in_con}->Input();

		if (@event && $event[5] < 0) {
			# Special characters are returned as unsigned integer
			# (dunno why). Fix this.
			$event[5] = 256 + $event[5];
		}
		if (@event && $event[0] == 1 && $event[1] == 0 && $event[3] == 18) {
			# Alt was released and there's an ASCII code. This is
			# a special character. Change @events as if a normal key
			# was pressed.
			$event[1] = 1;
		}

		#keyboard event
		if (@event && $event[0] == 1 && $event[1] == 1) {
			##Ctrl+U (erases entire line)
			if ($event[6] == 40 && $event[5] == 21) {
				$self->{in_pos} = 0;
				$self->{out_con}->Scroll(
					0, $self->{in_line}, $self->{right}, $self->{in_line},
					-$self->{right}, $self->{in_line}, ord(' '), $ATTR_NORMAL, 
					0, $self->{in_line}, $self->{right}, $self->{in_line},
				);
				$self->{out_con}->Cursor(0, $self->{in_line});
				$self->{input_part} = '';
			##Backspace
			} elsif ($event[5] == 8) {
				$self->{in_pos}-- if $self->{in_pos} > 0;
				substr($self->{input_part}, $self->{in_pos}, 1, '');
				$self->{out_con}->Scroll(
					$self->{in_pos}, $self->{in_line}, $self->{right}, $self->{in_line},
					$self->{in_pos}-1, $self->{in_line}, ord(' '), $ATTR_NORMAL, 
					$self->{in_pos}, $self->{in_line}, $self->{right}, $self->{in_line},
				);
				$self->{out_con}->Cursor($self->{in_pos}, $self->{in_line});
#				print "\010 \010";
			##Enter
			} elsif ($event[5] == 13) {
				my $ret = $self->{out_con}->Scroll(
					$self->{left}, 0, $self->{right}, $self->{in_line},
					0, -1, ord(' '), $ATTR_NORMAL, 
					$self->{left}, 0, $self->{right}, $self->{in_line}
				);
				$self->{out_con}->Cursor(0, $self->{in_line});
				$self->{in_pos} = 0;
				$self->{input_list}[0] = $self->{input_part};
				if ($self->{input_part} ne ""
				 && ( @{$self->{input_list}} < 2 || $self->{input_list}[1] ne $self->{input_part} )) {
					unshift(@{ $self->{input_list} }, "");
				}
				push @{ $self->{input_lines} }, $self->{input_part};
				$self->{out_col} = 0;
				$self->{input_offset} = 0;
				$self->{input_part} = '';
#				print "\n";
			#Other ASCII (+ ISO Latin-*)
			} elsif ($event[5] != 0) {#$event[5] >= 32 && $event[5] != 127 && $event[5] <= 255) {
				my $char = chr($event[5]);#Encode::decode('cp' . $self->{codepage}, chr($event[5]));
				if ($self->{in_pos} < length($self->{input_part})) {
					$self->{out_con}->Scroll(
						$self->{in_pos}, $self->{in_line}, $self->{right}, $self->{in_line},
						$self->{in_pos}+1, $self->{in_line}, ord(' '), $ATTR_NORMAL, 
						$self->{in_pos}, $self->{in_line}, $self->{right}, $self->{in_line},
					);
				} elsif ($self->{in_pos} > length($self->{input_part})) {
					$self->{in_pos} = length($self->{input_part});
				}
				$self->{out_con}->Cursor($self->{in_pos}, $self->{in_line});
				$self->{out_con}->Write($char);
				substr($self->{input_part}, $self->{in_pos}, 0, $char) if ($self->{in_pos} <= length($self->{input_part}));
				$self->{in_pos} += length($char);
#			} elsif ($event[3] == 33) {
#				__PACKAGE__->writeOutput("pgup\n");
#			} elsif ($event[3] == 34) {
#				__PACKAGE__->writeOutput("pgdn\n");
			##End
			} elsif ($event[3] == 35) {
				$self->{out_con}->Cursor($self->{in_pos} = length($self->{input_part}), $self->{in_line});
			##Home
			} elsif ($event[3] == 36) {
				$self->{out_con}->Cursor($self->{in_pos} = 0, $self->{in_line});
			##Left Arrow
			} elsif ($event[3] == 37) {
				$self->{in_pos}--;
				$self->{out_con}->Cursor($self->{in_pos}, $self->{in_line});
			##Up Arrow
			} elsif ($event[3] == 38) {
				unless ($self->{input_offset}) {
					$self->{input_list}[$self->{input_offset}] = $self->{input_part};
				}
				$self->{input_offset}++;
				$self->{input_offset} = $#{$self->{input_list}} if ($self->{input_offset} > $#{$self->{input_list}});
				#$self->{input_offset} -= $#{ $self->{input_list} } + 1 while $self->{input_offset} > $#{ $self->{input_list} };

				$self->{out_con}->Cursor(0, $self->{in_line});
				$self->{out_con}->Write(' ' x length($self->{input_part}));
				$self->{out_con}->Cursor(0, $self->{in_line});
				$self->{input_part} = $self->{input_list}[$self->{input_offset}];
				$self->{out_con}->Write($self->{input_part});
				$self->{in_pos} = length($self->{input_part});
			##Right Arrow
			} elsif ($event[3] == 39) {
				if ($self->{in_pos} + 1 <= length($self->{input_part})) {
					$self->{in_pos}++;
					$self->{out_con}->Cursor($self->{in_pos}, $self->{in_line});
				}
			##Down Arrow
			} elsif ($event[3] == 40) {
				unless ($self->{input_offset}) {
					$self->{input_list}[$self->{input_offset}] = $self->{input_part};
				}
				$self->{input_offset}--;
				$self->{input_offset} = 0 if ($self->{input_offset} < 0);
				#$self->{input_offset} += $#{ $self->{input_list} } + 1 while $self->{input_offset} < 0;

				$self->{out_con}->Cursor(0, $self->{in_line});
				$self->{out_con}->Write(' ' x length($self->{input_part}));
				$self->{out_con}->Cursor(0, $self->{in_line});
				$self->{input_part} = $self->{input_list}[$self->{input_offset}];
				$self->{out_con}->Write($self->{input_part});
				$self->{in_pos} = length($self->{input_part});
			##Insert
#			} elsif ($event[3] == 45) {
#				__PACKAGE__->writeOutput("insert\n");
			##Delete
			} elsif ($event[3] == 46) {
				substr($self->{input_part}, $self->{in_pos}, 1, '');
				$self->{out_con}->Scroll(
					$self->{in_pos}, $self->{in_line}, $self->{right}, $self->{in_line},
					$self->{in_pos} - 1, $self->{in_line}, ord(' '), $ATTR_NORMAL, 
					$self->{in_pos}, $self->{in_line}, $self->{right}, $self->{in_line},
				);
			##F1-F12
#			} elsif ($event[3] >= 112 && $event[3] <= 123) {
#				__PACKAGE__->writeOutput("F" . ($event[3] - 111) . "\n");
#			} else {
#				__PACKAGE__->writeOutput(join '-', @event, "\n");
			}
#		} else {
#			__PACKAGE__->writeOutput(join '-', @event, "\n");
		} elsif (@event && $event[0] == 2) {
			#mouse event
		}
	}	
}

sub title {
	my $self = shift;
	my $title = shift;

	if (defined $title) {
		if (!defined $self->{currentTitle} || $self->{currentTitle} ne $title) {
			$self->{out_con}->Title($title);
			$self->{currentTitle} = $title;
		}
	} else {
		return $self->{out_con}->Title();
	}
}

if (defined($main::ATTR_NORMAL)) {

	%fgcolors = (
	'reset'		=> $main::ATTR_NORMAL,
	'default'	=> $main::ATTR_NORMAL,
	'black'		=> $main::FG_BLACK,
	'darkgray'	=> FOREGROUND_INTENSITY(),
	'darkgrey'	=> FOREGROUND_INTENSITY(),
	'darkred'	=> $main::FG_RED,
	'red'		=> $main::FG_LIGHTRED,
	'darkgreen'	=> $main::FG_GREEN,
	'green'		=> $main::FG_LIGHTGREEN,
	'brown'		=> $main::FG_BROWN,
	'yellow'	=> $main::FG_YELLOW,
	'darkblue'	=> $main::FG_BLUE,
	'blue'		=> $main::FG_LIGHTBLUE,
	'darkmagenta'	=> $main::FG_MAGENTA,
	'magenta'	=> $main::FG_LIGHTMAGENTA,
	'darkcyan'	=> $main::FG_CYAN,
	'cyan'		=> $main::FG_LIGHTCYAN,
	'gray'		=> $main::FG_GRAY,
	'grey'		=> $main::FG_GRAY,
	'white'		=> $main::FG_WHITE,
	);
} else {
	%fgcolors = (
	'reset'		=> $Win32::Console::ATTR_NORMAL,
	'default'	=> $Win32::Console::ATTR_NORMAL,
	'black'		=> $Win32::Console::FG_BLACK,
	'darkgray'	=> FOREGROUND_INTENSITY(),
	'darkgrey'	=> FOREGROUND_INTENSITY(),
	'darkred'	=> $Win32::Console::FG_RED,
	'red'		=> $Win32::Console::FG_LIGHTRED,
	'darkgreen'	=> $Win32::Console::FG_GREEN,
	'green'		=> $Win32::Console::FG_LIGHTGREEN,
	'brown'		=> $Win32::Console::FG_BROWN,
	'yellow'	=> $Win32::Console::FG_YELLOW,
	'darkblue'	=> $Win32::Console::FG_BLUE,
	'blue'		=> $Win32::Console::FG_LIGHTBLUE,
	'darkmagenta'	=> $Win32::Console::FG_MAGENTA,
	'magenta'	=> $Win32::Console::FG_LIGHTMAGENTA,
	'darkcyan'	=> $Win32::Console::FG_CYAN,
	'cyan'		=> $Win32::Console::FG_LIGHTCYAN,
	'gray'		=> $Win32::Console::FG_GRAY,
	'grey'		=> $Win32::Console::FG_GRAY,
	'white'		=> $Win32::Console::FG_WHITE,
	);
}



#   I  R  G  B

# 128 64 32 16

if (defined($main::BG_BLACK)) {

	%bgcolors = (
	''		=> $main::BG_BLACK,
	'default'	=> $main::BG_BLACK,
	'black'		=> $main::BG_BLACK,
	'darkgray'	=> BACKGROUND_INTENSITY(),
	'darkgrey'	=> BACKGROUND_INTENSITY(),
	'darkred'	=> $main::BG_RED,
	'red'		=> $main::BG_LIGHTRED,
	'darkgreen'	=> $main::BG_GREEN,
	'green'		=> $main::BG_LIGHTGREEN,
	'brown'		=> $main::BG_BROWN,
	'yellow'	=> $main::BG_YELLOW,
	'darkblue'	=> $main::BG_BLUE,
	'blue'		=> $main::BG_LIGHTBLUE,
	'darkmagenta'	=> $main::BG_MAGENTA,
	'magenta'	=> $main::BG_LIGHTMAGENTA,
	'darkcyan'	=> $main::BG_CYAN,
	'cyan'		=> $main::BG_LIGHTCYAN,
	'gray'		=> $main::BG_GRAY,
	'grey'		=> $main::BG_GRAY,
	'white'		=> $main::BG_WHITE,
	);
} else {
	%bgcolors = (
	''		=> $Win32::Console::BG_BLACK,
	'default'	=> $Win32::Console::BG_BLACK,
	'black'		=> $Win32::Console::BG_BLACK,
	'darkgray'	=> BACKGROUND_INTENSITY(),
	'darkgrey'	=> BACKGROUND_INTENSITY(),
	'darkred'	=> $Win32::Console::BG_RED,
	'red'		=> $Win32::Console::BG_LIGHTRED,
	'darkgreen'	=> $Win32::Console::BG_GREEN,
	'green'		=> $Win32::Console::BG_LIGHTGREEN,
	'brown'		=> $Win32::Console::BG_BROWN,
	'yellow'	=> $Win32::Console::BG_YELLOW,
	'darkblue'	=> $Win32::Console::BG_BLUE,
	'blue'		=> $Win32::Console::BG_LIGHTBLUE,
	'darkmagenta'	=> $Win32::Console::BG_MAGENTA,
	'magenta'	=> $Win32::Console::BG_LIGHTMAGENTA,
	'darkcyan'	=> $Win32::Console::BG_CYAN,
	'cyan'		=> $Win32::Console::BG_LIGHTCYAN,
	'gray'		=> $Win32::Console::BG_GRAY,
	'grey'		=> $Win32::Console::BG_GRAY,
	'white'		=> $Win32::Console::BG_WHITE,
	);
}

1;