class toto {
 $x=tsubsys_list($tsystem_name,$tsystem_version,$tsubsystem_name)
 
 $x[0].each |$inx,$v| {
  notify{"msg_${inx}": message=>"${v}"}
 }
 notify{"msg_cmd": message=>"${x[1]}"}
}
