class  lvm2::vg ($stage='main',$vglist={}) {
 if is_hash($vglist) == false {
  fail('$vglist is not valid hash')
 }
 $vglist.each | $k,$v | {
  $disk_array=itemize2array($v)
  vg {$k :
   ensure=> present,
   disks=> $disk_array,
  }
 }
 Class['lvm2::vg'] ~> Class['lvm2::fs']
}
