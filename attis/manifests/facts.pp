#
#define facts according to the variable list ($fact_list). Each item must have only the global variable name without prefix "$"
#
# stage: class running stage
#
# fact_list: list of facts to setup on client node
#
class attis::facts ($stage='main',$fact_list=[])
inherits attis
{
	$conf_dir=$param['config_dir']
	$fact_list.each |$ft| {
		if defined("$${ft}") {
			file { "${conf_dir}/${ft}.fact":
				content=> getvar($ft);
			}
		}
	}	
}
