class netservices::repos($stage = 'main',$lst='empty_repos_list',$purge_dir = true )
{
	file {'/etc/yum.repos.d':
		ensure=> directory,
		purge=> $purge_dir,
		recurse=> true,
	}
	$lst2 = eval2 ($lst)
	$lst2.each |$v| {
			yumrepo{ $v['name']:
  			ensure=> present,
  			baseurl=> "http://${repo_server}/${v['path']}",
  			descr=> $v['name'],
  			enabled=> '1',
  			gpgcheck=> '0',
			require=> File['/etc/yum.repos.d'],
		}

	}
}
