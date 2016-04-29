class netservices::packages($stage='main',$pkglist={})
{
 unless is_hash($pkglist) { fail("pkglist is not hash")}
 $pkglist.each | $k,$v | {
  $v_list=split($v,':')
  if empty($v_list[0]) {
   $etat="installed"
  }
  else {
   $etat=$v_list[0]
  }
  if empty($v_list[1]) {
   $src="yum"
  }
  else {
   $src=$v_list[1]
  }
  if $k =~ /^@/ {
   $k1= regsubst($k,'^@','')
   yumgroup {$k1:
    ensure=> $etat,
   }
  }
  else
  {
   package {$k:
    ensure=> $etat,
    provider=> $src,
   }
  }
 }
}
