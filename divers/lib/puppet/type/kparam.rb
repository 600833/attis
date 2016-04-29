Puppet::Type.newtype(:kparam) do
    @doc = "Changer le parametre du noyau linux"
#    ensurable

    newparam(:nom) do
     isnamevar
     desc "nom du parametre"
    end

    newproperty(:valeur) do
     desc "valeur du parametre"
    end

end
