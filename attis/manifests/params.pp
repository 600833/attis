#
#settings of attis and getting values of parameters from hiera
#
class attis::params
{
 $param=hiera("attis_params")
}
