class attis::facts ($stage='main',$fact_list=[])
{
	$conf_dir='/CONFIG'
	$fact_list.each |$ft| {
		if defined("$${ft}") {
			file { "${conf_dir}/${ft}.fact":
				content=> getvar($ft);
			}
		}
	}	
}
