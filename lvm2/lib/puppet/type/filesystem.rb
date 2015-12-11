#management filesystem
Puppet::Type.newtype(:filesystem) do
 @doc = %Q(Creation d'un system de fichier dans un volume groupe LVM2)
 
 ensurable
 newparam(:device) do
  desc "Fichier special du volume logique example: /dev/datavg/lv_tomcat_data"
 end
 newproperty(:size) do
  desc "Taille du volume exemple: 10M , ou 1G"
 end
 newparam(:fstype) do
  desc "Type de systeme des fichiers exemple: ext4, xfs"
 end
 newparam(:mnt) do
  isnamevar
  desc "point de montage"
 end
 newproperty(:mount) do
  desc "mount=>true or false"
 end
 newproperty(:owner) do
  desc "proprietaire du point de montage"
 end
 newproperty(:group) do
  desc "groupe proprietaire du point de montage"
 end
 newparam(:mnt_options) do
  desc "options de montage"
 end
end
