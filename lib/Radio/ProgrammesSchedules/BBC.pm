package Radio::ProgrammesSchedules::BBC;

use strict; use warnings;

use overload q("") => \&as_string, fallback => 1;

use Carp;
use Readonly;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;
use HTML::Entities;
use Time::localtime;

=head1 NAME

Radio::ProgrammesSchedules::BBC - Interface to BBC Radio Programmes Schedules.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

Readonly my $BASE_URL => 'http://www.bbc.co.uk';
Readonly my $CHANNELS =>
{
    radio1             => 'Radio 1',
    '1xtra'            => '1Xtra',
    radio2             => 'Radio 2',
    radio3             => 'Radio 3',
    radio4             => 'Radio 4',
    radio4extra        => 'Radio 4 Extra',
    '5live'            => '5 Live',
    '5livesportsextra' => '5 Live Sports Extra',
    '6music'           => '6 Music',
    aisannetwork       => 'Asian Network',
    worldservice       => 'World Service'
};

Readonly my $LOCATIONS =>
{
    radio1 => { england         => 'England',
                northernireland => 'Northern Ireland',
                scotland        => 'Scotland',
                wales           => 'Wales' },
};

Readonly my $FREQUENCIES =>
{
    radio4 => { fm => 'FM',
                lw => 'LW' }
};

=head1 DESCRIPTION

Each week, nearly 35 million people listen to BBC Radio.The BBC offers a portfolio of services
aimed at offering listeners the highest quality programmes, whatever their interest or mood.It
includes the following:

=over 5

=item * Music radio on Radio 1, Radio 1Xtra, Radio 2, 6 Music and Asian Network.

=item * Classical music and jazz on Radio 3.

=item * Speech, drama, analysis and the arts on Radio 4.

=item * Comedy, drama and children's programming on Radio 4 Extra.

=item * News and sport on 5 live and 5 live sports extra.

and many more.

=back

=head1 CONSTRUCTOR

The  module provides programmes schedules for Radio 1, 1Xtra, Radio 2, Radio 3, Radio 4, Radio
4 Extra, 5 Live, 5 Live Sports Extra, 6 Music, Asian Network and World Service.The constructor
expects  a  reference  to an anonymous hash as input parameter. Table below shows the possible
value  of  various key ( channel, location, frequency, yyyy, mm, dd ). The yyyy, mm and dd are
optional. If missing picks up the current year, month and day.

    +---------------------+------------------+-----------------+-----------+------+----+----+
    | Name                | Channel          | Location        | Frequency | YYYY | MM | DD |
    +---------------------+------------------+-----------------+-----------+------+----+----+
    | Radio 1             | radio1           | england         | N/A       | 2011 | 11 | 15 |
    |                     |                  | northernireland |           |      |    |    |
    |                     |                  | scotland        |           |      |    |    |
    |                     |                  | wales           |           |      |    |    |
    |                     |                  |                 |           |      |    |    |
    | Radio 1Xtra         | 1xtra            | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | Radio 2             | radio2           | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | Radio 3             | radio3           | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | Radio 4             | radio4           | N/A             | fm        | 2011 | 11 | 15 |
    |                     |                  |                 | lw        |      |    |    |
    |                     |                  |                 |           |      |    |    |
    | Radio 4 Extra       | radio4extra      | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | 5 Live              | 5live            | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | 5 Live Sports Extra | 5livesportsextra | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | 6 Music             | 6music           | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | Asian Network       | asiannetwork     | N/A             | N/A       | 2011 | 11 | 15 |
    |                     |                  |                 |           |      |    |    |
    | World Service       | worldservice     | N/A             | N/A       | 2011 | 11 | 15 |
    +---------------------+------------------+-----------------+-----------+------+----+----+

    use strict; use warnings;
    use Radio::ProgrammesSchedules::BBC;

    my ($bbc);

    # BBC Radio 1
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio1', location => 'england' });

    # BBC Radio 1Xtra
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => '1xtra' });

    # BBC Radio 2
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio2' });

    # BBC Radio 3
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio3' });

    # BBC Radio 4
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio4', frequency => 'fm' });

    # BBC Radio 4 Extra
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio4extra' });

    # BBC 5 Live
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => '5live' });

    # BBC 5 Live Sports Extra
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => '5livesportsextra' });

    # BBC 6 Music
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => '6music' });

    # BBC Asian Network
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'aisannetwork' });

    # BBC World Service
    $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'worldservice' });

=cut

sub new
{
    my $class = shift;
    my $param = shift;

    _validate_param($param);
    my $self  = $param;
    bless $self, $class;
    $self->_build_listings();

    return $self;
}

=head1 METHODS

=head2 get_listings()

Return the schedules listings as reference to an array of anonymous hash containing start time
, end time, short description and url to get more detail of each program.

    use strict; use warnings;
    use Radio::ProgrammesSchedules::BBC;

    my $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio1', location => 'england' });
    my $listings = $bbc->get_listings();

=cut

sub get_listings
{
    my $self = shift;
    return $self->{listings};
}

=head2 as_xml()

Returns listings in XML format.

    use strict; use warnings;
    use Radio::ProgrammesSchedules::BBC;

    my $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio1', location => 'england' });
    print $bbc->as_xml();

=cut

sub as_xml
{
    my $self = shift;
    my ($xml, $listings);

    $self->{listings} = $self->get_listings()
        unless defined($self->{listings});

    $xml = qq {<?xml version="1.0" encoding="UTF-8"?>\n};
    $xml.= qq {<programmes>\n};
    foreach (@{$self->{listings}})
    {
        $xml .= qq {\t<programme>\n};
        $xml .= qq {\t\t<starttime> $_->{start_time} </starttime>\n};
        $xml .= qq {\t\t<endtime> $_->{end_time} </endtime>\n};
        $xml .= qq {\t\t<title> $_->{title} </title>\n};
        $xml .= qq {\t\t<url> $_->{url} </url>\n};
        $xml .= qq {\t</programme>\n};
    }
    $xml.= qq {</programmes>};
    return $xml;
}

=head2 as_string()

Returns listings in a human readable format.

    use strict; use warnings;
    use Date::Holidays::PAK;

    my $bbc = Radio::ProgrammesSchedules::BBC->new({ channel => 'radio1', location => 'england' });

    print $bbc->as_string();

    # or even simply
    print $bbc;

=cut

sub as_string
{
    my $self = shift;
    my ($listings);
    foreach (@{$self->{listings}})
    {
        $listings .= sprintf("Start Time: %s\n", $_->{start_time});
        $listings .= sprintf("  End Time: %s\n", $_->{end_time});
        $listings .= sprintf("     Title: %s\n", $_->{title});
        $listings .= sprintf("       URL: %s\n", $_->{url});
        $listings .= "-------------------\n";
    }
    return $listings;
}

sub _build_listings
{
    my $self = shift;

    my $url   = sprintf("%s/%s/programmes/schedules", $BASE_URL, $self->{channel});
    $url .= '/'. $self->{location}
        if (defined($self->{location}) && exists($LOCATIONS->{$self->{channel}}->{$self->{location}}));
    $url .= '/'. $self->{frequency}
        if (defined($self->{frequency}) && exists($FREQUENCIES->{$self->{channel}}->{$self->{frequency}}));

    unless (defined($self->{yyyy}) && defined($self->{mm}) && defined($self->{dd}))
    {
        my $today = localtime;
        $self->{yyyy} = $today->year+1900;
        $self->{mm}   = $today->mon+1;
        $self->{dd}   = $today->mday;
    }
    $url .= '/'. join("/", $self->{yyyy}, $self->{mm}, $self->{dd}, "ataglance");

    my $browser  = LWP::UserAgent->new();
    my $request  = HTTP::Request->new(GET=>$url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't connect to [$url].\n")
        unless $response->is_success;

    my ($contents, $listings, $program, $count);
    $contents = $response->content;
    $count    = 0;

    foreach (split(/\n/,$contents))
    {
        chomp;
        s/^\s+//g;
        s/\s+$//g;
        next if /^$/;

        if (/\<span class=\"starttime\"\>(.*)\<\/span\>\<span class=\"endtime\"\>&#8211\;(.*)\<\/span\>/)
        {
            my($hh,$mm) = split/\:/,$1,2;
            last if ($count > 3 && $hh == 0);
            $program->{start_time} = $1;
            $program->{end_time}   = $2;
        }
        elsif (/class=\"url\" href=\"(.*)\"\>/)
        {
            $program->{url} = $BASE_URL . $1;
        }
        elsif (/class\=\"title\"\>(.*)\<\/span\>/)
        {
            $program->{title} = HTML::Entities::decode($1);
            push @$listings, $program if ((defined $program) && scalar(keys %{$program}) == 4);
            $program = undef;
            $count++;
        }
    }

    $self->{listings} = $listings;
}

sub _validate_param
{
    my $param = shift;

    croak("ERROR: Input param has to be a ref to HASH.\n")
        if (ref($param) ne 'HASH');
    croak("ERROR: Missing key channel.\n")
        unless exists($param->{channel});
    croak("ERROR: Invalid value for channel.\n")
        unless exists($CHANNELS->{$param->{channel}});
    croak("ERROR: Missing key mm from input hash.\n")
        if (defined($param->{yyyy}) && !exists($param->{mm}));
    croak("ERROR: Missing key dd from input hash.\n")
        if (defined($param->{yyyy}) && !exists($param->{dd}));
    croak("ERROR: Missing key yyyy from input hash.\n")
        if (defined($param->{mm}) && !exists($param->{yyyy}));
    croak("ERROR: Missing key dd from input hash.\n")
        if (defined($param->{mm}) && !exists($param->{dd}));
    croak("ERROR: Missing key yyyy from input hash.\n")
        if (defined($param->{dd}) && !exists($param->{yyyy}));
    croak("ERROR: Missing key mm from input hash.\n")
        if (defined($param->{dd}) && !exists($param->{mm}));
    my $count = 0;
    $count = 3 if (defined($param->{yyyy}) && defined($param->{mm}) && defined($param->{dd}));
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (($param->{channel} =~ /radio[1|4]/i) && (scalar(keys %{$param}) != (2+$count)));
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (($param->{channel} !~ /radio[1|4]/i) && (scalar(keys %{$param}) != (1+$count)));
    croak("ERROR: Missing key location.\n")
        if (($param->{channel} =~ /radio1/i) && !exists($param->{location}));
    croak("ERROR: Missing key frequency.\n")
        if (($param->{channel} =~ /radio4/i) && !exists($param->{frequency}));
    croak("ERROR: Invalid value for location.\n")
        if (($param->{channel} =~ /radio1/i) && !exists($LOCATIONS->{radio1}->{$param->{location}}));
    croak("ERROR: Invalid value for frequency.\n")
        if (($param->{channel} =~ /radio4/i) && !exists($FREQUENCIES->{radio4}->{$param->{frequency}}));
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bug/feature requests to C<bug-radio-programmesschedules-bbc at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Radio-ProgrammesSchedules-BBC>.
I  will  be  notified, and then you'll automatically be notified of progress  on your bug as I
make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Radio::ProgrammesSchedules::BBC

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Radio-ProgrammesSchedules-BBC>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Radio-ProgrammesSchedules-BBC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Radio-ProgrammesSchedules-BBC>

=item * Search CPAN

L<http://search.cpan.org/dist/Radio-ProgrammesSchedules-BBC/>

=back

=head1 ACKNOWLEDGEMENT

Radio::ProgrammesSchedules::BBC provides  information  from BBC official website. This  should
be used as it is without any modifications. BBC remains the sole owner of the data.  The terms
and condition for Personal and Non-business use can be found here:

http://www.bbc.co.uk/terms/personal.shtml.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of Radio::ProgrammesSchedules::BBC