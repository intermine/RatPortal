package RatPortal;
use Dancer ':syntax';
use Dancer::Plugin::ProxyPath;
use Template;

our $VERSION = '0.1';

use constant LIST_NAME => "Obesity Term List";

use Webservice::InterMine;

my $ratmine = get_service("development.ratmine.mcw.edu/ratmine", 'ratportal@mcw.edu', 'test');

get '/' => sub {
    my $list = $ratmine->list(LIST_NAME);
    my @categories;
    for (my $it = $list->results_iterator(as => "jsonobjects", json => 'inflate'); my $disease = <$it>;) {
        push @categories, $disease->name;
    }
    template 'index' => {
        list => $list,
        categories => [@categories],
    };
};

get '/childterms/of/:parent' => sub  {
    my $parent = param('parent');
    my $q = $ratmine->new_query(class => "DOTerm")->select("name")->where("parents.name" => $parent);
    debug("$q");
    my @childterms = $q->results(as => 'tsv');
    return template 'childterms' => {childterms => [@childterms]}, {layout => undef};
};

get '/genes/related/to/:term' => sub {
    my $term = param('term');
    my $query = $ratmine->new_query(class => 'Gene')->select("*", "goAnnotation.ontologyTerm.*")->where("doAnnotation.ontologyTerm.parents.name" => $term);
    my $genes = $query->results(as => "jsonobjects", json => "inflate");
    return template 'gene_info' => {genes => $genes}, {layout => undef};
};

true;
