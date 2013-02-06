#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

#TODO Refactor as module
do 'facebook_graphapi.pl';

use strict;

# use warnings;
# ISSUE WONTFIX HTTP::Tiny does not support returning the redirected URL i.e. ->request->uri->as_string
use LWP::UserAgent;
use URI;
use Data::Dumper;
use Digest::SHA;

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments;

my $VERSION = "0.0_8"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

# Command line arguments from Maltego
my $maltego_selected_entity_value = $ARGV[0];

# "###" is for Smart::Comments CPAN Module
### \$maltego_selected_entity_value is: $maltego_selected_entity_value;

my $maltego_additional_field_values = $ARGV[1];

# "###" is for Smart::Comments CPAN Module
### \$maltego_additional_field_values is: $maltego_additional_field_values;

my %maltego_additional_field_values =
  split_maltego_additional_fields($maltego_additional_field_values);
my $facebook_profileid = $maltego_additional_field_values{"uid"};

my $facebook_affiliation_name = $maltego_selected_entity_value;

# "###" is for Smart::Comments CPAN Module
### \$facebook_profileid is: $facebook_profileid;

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI Profile Cover Image Local Transform v$VERSION</UIMessage>\n"
);

# TODO ?types=small,normal,square,large
my $facebook_graphapi_URL =
  "https://graph.facebook.com/$facebook_profileid/picture?type=large";

# TODO Replace LWP with WWW::Mechanize CPAN Module
# TODO Replace LWP with libwhisker
my $http_request = LWP::UserAgent->new;
$http_request->agent('Mozilla/5.0');

# TODO Availability of $facebook_graphapi_URL i.e. is "up" and resulting HTTP Status Code
my $http_response = $http_request->head($facebook_graphapi_URL);
my $facebook_graphapi_redirect_URL = $http_response->request->uri->as_string;

# "###" is for Smart::Comments CPAN Module
### \$facebook_graphapi_redirect_URL is: $facebook_graphapi_redirect_URL;

my $facebook_affiliation_filename = $facebook_affiliation_name;
$facebook_affiliation_filename =~ s/\s//g;

# "###" is for Smart::Comments CPAN Module
### \$facebook_affiliation_filename.jpg is: "./Images/Pictures/$facebook_affiliation_filename.jpg"
#TODO Refactor as sub() {}
if ( -e "./Images/Pictures/$facebook_affiliation_filename.jpg" ) {
    open PICTURE_JPG, "./Images/Pictures/$facebook_affiliation_filename.jpg";
    my $sha = new Digest::SHA;
    $sha->addfile(*PICTURE_JPG);
    close PICTURE_JPG;
    my $hex = $sha->hexdigest();
    print(
"\t\t<UIMessage MessageType=\"Inform\">SHA of previous $facebook_affiliation_filename.jpg is $hex</UIMessage>\n"
    );
}
else {
    print
"\t\t<UIMessage MessageType=\"Inform\">./Images/Pictures/$facebook_affiliation_filename.jpg does not exist</UIMessage>\n";
}

#TODO Refactor as sub() {}
$http_request->mirror( $facebook_graphapi_redirect_URL,
    "./Images/Pictures/$facebook_affiliation_filename.jpg" );
#TODO mkdir /Images/Pictures if it does not exist
open PICTURE_JPG, "./Images/Pictures/$facebook_affiliation_filename.jpg";
my $sha = new Digest::SHA;
$sha->addfile(*PICTURE_JPG);
close PICTURE_JPG;
my $hex = $sha->hexdigest();
print(
"\t\t<UIMessage MessageType=\"Inform\">SHA of recent $facebook_affiliation_filename.jpg is $hex</UIMessage>\n"
);
print("\t</UIMessages>\n");

print("\t<Entities>\n");
my $shortern_hash = substr($hex, 0, 4);
print("\t\t<Entity Type=\"maltego.image\"><Value>Picture - $shortern_hash</Value>\n");
print("\t\t\t<AdditionalFields>\n");
print("\t\t\t\t<Field Name=\"url\">$facebook_graphapi_redirect_URL</Field>\n");
print("\t\t\t</AdditionalFields>\n");
print("\t\t\t<IconURL>$facebook_graphapi_URL</IconURL>\n");
print("\t\t</Entity>\n");

print("\t\t<Entity Type=\"maltego.URL\"><Value>Picture - $shortern_hash</Value>\n");
print("\t\t\t<AdditionalFields>\n");
print("\t\t\t\t<Field Name=\"url\">$facebook_graphapi_redirect_URL</Field>\n");
print("\t\t\t\t<Field Name=\"title\">$facebook_affiliation_name</Field>\n");
print("\t\t\t</AdditionalFields>\n");
print("\t\t\t<IconURL>$facebook_graphapi_redirect_URL</IconURL>\n");
print("\t\t</Entity>\n");

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

from_affliation_facebook-to_user_picture.pl - "To Facebook Profile Image"

=head1 VERSION

This documentation refers "To Facebook Profile Image" Alpha $VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

from_affliation_facebook-to_facebook_profile_image.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Image, URL and its Facebook Object in Maltego via the Facebook GraphAPI

=head1 DEPENDENCIES

=head1 PREREQUISITES

LWP::UserAgent
URI

=head1 COREQUISITES

=head1 INSTALLATION

=head1 OSNAMES

osx

=head1 SCRIPT CATEGORIES

Web

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

Please refer to the comments beginning with "TODO" in the Perl Code.

=head1 AUTHOR

Christian Heinrich

=head1 CONTACT INFORMATION

http://cmlh.id.au/contact

=head1 MAILING LIST

=head1 REPOSITORY

http://github.com/cmlh/

=head1 FURTHER INFORMATION AND UPDATES

http://cmlh.id.au/tagged/maltego

=head1 LICENSE AND COPYRIGHT

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 

Copyright 2012 Christian Heinrich


