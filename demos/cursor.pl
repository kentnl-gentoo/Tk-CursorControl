#CursorControl, Manipulate the cursor programmatically.

use Tk;
use Tk::CursorControl;

use vars qw/$TOP/;
use subs qw/toggleit warpit items_start_drag items_drag/;
use vars qw/$dir $cursor $direction $trans $place %info $jail %wid $event $r $c @coords/;


sub cursor {
        my ($demo) = @_;
my $text = qq/
Warp, confine and hide your mouse pointer!
Use the controls below to warp
(aka 'move') the cursor to any part of the screen
or any part of a widget. The nine Radiobuttons and
the Optionmenu are used to control your target. 
You can also make the cursor
disappear when it is over the canvas. The "Hide Cursor" button
controls whether or not you can see the cursor when it is over
the canvas. The "Confine Cursor" button will determine whether
or not to confine your mouse cursor to the canvas on a buttonpress.
Try moving the rectangle via B1 Click and drag, with this feature
on or off. See the difference?
See perldoc Tk::CursorControl for more information./;
$text=~s/\n/ /g;
        $TOP = $MW->WidgetDemo(
                -name => $demo,
                -text => $text,
                -title=> 'CursorControl Demonstration',
                -iconname=>'Cursor',
                -geometry_manager => 'grid',
                );

$direction='c';
$trans='show';
$place='Screen';
$jail=1;

$cursor=$TOP->CursorControl;
$wid{frame} = $TOP->Frame( -relief=>'sunken', -bd=>3)->grid(
    -row=>0,
    -column=>0,
    -columnspan=>4,
    -sticky=>'nsew');    
$wid{canvas} = $wid{frame}->Canvas(
    -width=>240,
    -height=>240,
    -bg=>'papayawhip',
    -bd=>0,
    -highlightthickness=>0)->grid(-sticky=>'nsew');

$wid{canvas}->create('rectangle', 10,10,60,60,-fill=>'sienna',-tags=>['RECT']);

$wid{canvas}->Tk::bind('<1>' => sub {
    $event = $wid{canvas}->XEvent;
	  $cursor->confine($wid{canvas}) if ($jail);
	  &items_start_drag ($event->x, $event->y);
    });
$wid{canvas}->Tk::bind('<B1-Motion>' =>
        sub {&items_drag ($Tk::event->x, $Tk::event->y);});
$wid{canvas}->Tk::bind('<ButtonRelease-1>' =>
        sub {$cursor->release if ($jail);});
     
$TOP->Button(
    -text => 'WARP !',
    -command=>\&warpit)->grid(
    -row=>3,
    -column=>3,
    -rowspan=>2,
    -sticky=>'nsew');

$dir = {
	'nw' => [0,0],
	'n'  => [0.5,0],
	'ne' => [1.0,0],
	'w'  => [0,0.5],
	'c'  => [0.5,0.5],
	'e'  => [1.0,0.5],
	'sw' => [0,1.0],
	's'  => [0.5,1.0],
	'se' => [1.0,1.0],
	};

$r=0;
$c=0;
foreach (qw/nw n ne w c e sw s se/){
    $r++ unless ( $c%3 );
    $c=0 unless ( $c%3 );
		$TOP->Radiobutton(
			-value=>$_,
			-variable=>\$direction)->grid(
			-row=>$r,
			-column=>$c,
            -sticky=>'w');
    $c++;
}
$TOP->Optionmenu(-textvariable=>\$place,
    -options=>['Screen','Canvas','Rectangle Item'])->grid(
    -row=>4,
    -column=>0,
    -sticky=>'nsew',
    -columnspan=>3);

$TOP->Checkbutton(
    -text=>"Hide Cursor",
    -onvalue=>'hide',
    -offvalue=>'show',
    -variable=>\$trans,
    -command=>\&toggleit)->grid(-row=>1, -column=>3, -sticky=>'w');
$TOP->Checkbutton(
    -text=>"Confine Cursor",
    -variable=>\$jail)->grid(-row=>2, -column=>3, -sticky=>'w');

}

sub toggleit {
   	$cursor->${trans}($wid{canvas});
}

sub warpit {
    if ($place eq 'Screen'){
        $cursor->warpto(
            $TOP->screenwidth*$dir->{$direction}[0],
            $TOP->screenheight*$dir->{$direction}[1]
        );
    }
    elsif($place eq 'Canvas'){
        $cursor->warpto(
            $wid{canvas},
            $wid{canvas}->width  * $dir->{$direction}[0],
            $wid{canvas}->height * $dir->{$direction}[1]
        );
    }
    elsif($place eq 'Rectangle Item'){
        @coords = $wid{canvas}->coords('RECT');
        $cursor->warpto(
            $wid{canvas},
            ($coords[2] - $coords[0])  * $dir->{$direction}[0] + $coords[0],
            ($coords[3] - $coords[1])  * $dir->{$direction}[1] + $coords[1],
        );

    }
}

sub items_start_drag {

    ($x, $y) = @_;

    $iinfo->{lastX} = $wid{canvas}->canvasx($x);
    $iinfo->{lastY} = $wid{canvas}->canvasy($y);

}

sub items_drag {

    ($x, $y) = @_;

    $x = $wid{canvas}->canvasx($x);
    $y = $wid{canvas}->canvasy($y);
    $wid{canvas}->move('current', $x-$iinfo->{lastX}, $y-$iinfo->{lastY});
    $iinfo->{lastX} = $x;
    $iinfo->{lastY} = $y;

}

return 1 if caller();

require WidgetDemo;

$MW = new MainWindow;
$MW->geometry("+0+0");
$MW->Button(-text=>'Close',
    -command=>sub {$MW->destroy})->pack;
cursor('cursor');
MainLoop;
