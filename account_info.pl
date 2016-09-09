# Rewrite nicknames to indicate services account information if available
# Nicks will be shown with a ~ if not identified
# if identified to an account other than the current nickname account name in brackets will be appended

sub weechat_print_cb {
  my $message= $_[3];
  my ($plugin, $buffer, $args)=split /;/,$_[2];
  my ($server, $channel) = split /\./,$buffer,2;
  my $nick;
  my $dnick;

  if ($args=~/^irc_(notice|privmsg)/) {
   foreach $arg (split /,/, $args) {
     if ($arg=~/^nick_(\S+)/) { 
       $nick=$1;
       $dnick=$nick;
       last;
     }
   }
    if ($channel && $channel=~/^\#/) {
    my $infolist = weechat::infolist_get( "irc_nick", '', "$server,$channel,$nick");
    weechat::infolist_next($infolist);
    my $account=weechat::infolist_string( $infolist, "account");
    if (!$account) {
      $dnick = "~$nick";
    } elsif ($account && $account ne $nick) {
      $dnick="$nick($account)";
    } 

    weechat::infolist_free($infolist);

    my $qnick=quotemeta($nick);
    $message=~s{$qnick}{$dnick};
  }
 }
 return $message;
}
sub account_info_hook {
  weechat::hook_modifier("weechat_print", "weechat_print_cb", "");
}

if (!weechat::register("account_info", "mquin", "0.1", "GPL2", "Rewrite irc nicknames to indicate services identification", "", ""))
{
        # Double load
        weechat::print ("", "\taccount_info is already loaded");
        return weechat::WEECHAT_RC_OK;
}
else
{
        # Start everything
        account_info_hook();
}
