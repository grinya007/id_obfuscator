package Obfuscator;
use 5.018;
no if $] >= 5.018, warnings => "experimental";

use Digest::xxHash qw/xxhash/;
use MIME::Base64 qw/encode_base64url decode_base64url/;

sub ID_SECRET { 0xDEADBEEF }

sub obfuscate {
    use bytes;
    my ($id) = @_;
    die('bad int') unless (defined($id) && int($id) eq $id);
    my $hash = pack('N', xxhash($id, 0));
    my $pack = 'N';
    my $secret = ID_SECRET();
    if ($id % 2) {
        $pack = 'L';
        $secret++;
    }
    $secret = pack('L', $secret);
    my $xored_id = pack($pack, $id) ^ $hash;
    my $obf_id = '';
    for (0..3) {
        $obf_id .= substr($xored_id, $_, 1);
        $obf_id .= substr($secret, $_, 1);
        $obf_id .= substr($hash, $_, 1);
    }
    return encode_base64url($obf_id);
}

sub parse {
    use bytes;
    my ($obf_id) = @_;
    return undef unless ($obf_id);
    $obf_id = decode_base64url($obf_id);
    return undef if (length($obf_id) != 12);
    my (@secret, @xored_id, @hash);
    for (0..3) {
        ($xored_id[$_], $secret[$_], $hash[$_]) =
            split '', substr($obf_id, $_*3, 3);
    }
    my $secret = unpack('L', join('', @secret));
    my $unpack;
    if ($secret == ID_SECRET()) {
        $unpack = 'N';
    }
    elsif ($secret == ID_SECRET() + 1) {
        $unpack = 'L';
    }
    else {
        return undef;
    }
    my $id = unpack($unpack, join('', @xored_id) ^ join('', @hash));
    return undef if (xxhash($id, 0) != unpack('N', join('', @hash)));
    return $id;
}

1;
