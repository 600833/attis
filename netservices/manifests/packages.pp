class netservices::packages($stage='main',$pkglist='',$etat='present')
{
	unless empty($pkglist)
	{
		$vlist=split($pkglist,'[,;]')
		package {$vlist:
			ensure=>$etat
		}
	} 
}
