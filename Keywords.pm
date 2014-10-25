# $File: //member/autrijus/Lingua-ZH-Keywords/Keywords.pm $ $Author: autrijus $
# $Revision: #9 $ $Change: 3723 $ $DateTime: 2003/01/20 22:15:45 $

package Lingua::ZH::Keywords;
$Lingua::ZH::Keywords::VERSION = '0.04';

use strict;
use vars qw($VERSION @ISA @EXPORT @StopWords);

use Exporter;
use Lingua::ZH::TaBE ();

=head1 NAME

Lingua::ZH::Keywords - Extract keywords from Chinese text

=head1 SYNOPSIS

    # Exports keywords() by default
    use Lingua::ZH::Keywords;

    print join(",", keywords($text));	    # Prints five keywords
    print join(",", keywords($text, 10));   # Prints ten keywords

=head1 DESCRIPTION

This is a very simple algorithm which removes stopwords from the
text, and then counts up what it considers to be the most important
B<keywords>.  The C<keywords> subroutine returns a list of keywords
in order of relevance.

The stopwords list is accessible as C<@Lingua::ZH::Keywords::StopWords>.

If the input C<$text> is an Unicode string, the returned keywords
will also be Unicode strings; otherwise they are assumed to be
Big5-encoded bytestrings.

=cut

@ISA	    = qw(Exporter);
@EXPORT	    = qw(keywords);

@StopWords  = qw(
    ���� ���� �ڭ� �i�H �p�� �]�� �ثe �p�G ��L �ڪ� �j�a �S�� �D�n �ҥH
    �H�W �o�� �Ҧ� ���� �N�O �L�� �]�� ���O �H�� �O�_ �ѩ� ��� ���� ����
    �o�� �{�b �L�k ���� �i�� ���L �]�A ���� ���� �o�O �o�� �H�U �w�g �A��
    ���M �\�h �]�O ���O ���F �٬O ���F ���� �u�n �䤤 ���O �U�� �٦� �D�`
    �ӥB �o�� �䥦 ���n �ڭn �L�� �u�O �U�� �u�� ���� ���� �o�� �۷� �ڬO
    ���� �ܦh �i�O �άO ��� ���� �A�� �U�C �p�� �t�~ �M�� �U�� �~�� ���|
    �Ʀ� �`�| ���o ��� �Y�i �@�� �ܩ� ��M �ھ� �ڷQ ��� ���� ���� ����
    �Ҧp ���� �ɭ� �]�� �`�� �åB �e�� �ڦ� ��� ���H ���� ���O �ä� �H��
    �ϱo �g�� ���s �p�U �b�� �o�� ���� ��� ���� �o�� ���e �O�H �Ӫ� �N�|
    �W�z ��� ���� �Ӥw �ϥ� ���p ��O �ٱo �O�b �L�k ��p ���g �ڭ̪� 
);

my $Tabe;

sub keywords {
    $Tabe ||= Lingua::ZH::TaBE->new;

    eval { require Encode::compat } if $] < 5.007;
    my $is_utf8 = eval { require Encode; Encode::is_utf8($_[0]) };

    my (%hist, %ref);
    $hist{$_}++ for grep {
	length > 2 and index($_, '�@') == -1
    } $Tabe->split(
	$is_utf8 ? Encode::encode(big5 => $_[0]) : $_[0]
    );
    delete @hist{@StopWords};

    my $count = $_[1] || 5;

    # By occurence, then freq, then lexical order
    map {
	$is_utf8 ? Encode::decode(big5 => $_) : $_
    } grep length, (sort {
	$hist{$b} <=> $hist{$a}
	    or
	($ref{$b} ||= freq($b)) <=> ($ref{$a} ||= freq($a))
	    or
	$b cmp $a
    } keys %hist)[ 0 .. $count-1 ];
}

sub freq {
    my $tsi = $Tabe->Tsi($_[0]);
    $Tabe->TsiDB->Get($tsi);
    return $tsi->refcount;
}

1;

__END__

=head1 SEE ALSO

L<Lingua::ZH::TaBE>, L<Lingua::EN::Keywords>

=head1 ACKNOWLEDGEMENTS

Algorithm adapted from the L<Lingua::EN::Keywords> module by
Simon Cozens, E<lt>simon@simon-cozens.org<gt>.

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
