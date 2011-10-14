package RatPortal;
use Dancer ':syntax';

our $VERSION = '0.1';

use Webservice::InterMine;

my $ratmine = get_service("development.ratmine.mcw.edu/ratmine", 'ratportal@mcw.edu', 'test');

get '/' => sub {
    template 'index';
};

true;
