Puppet::Type.newtype(:rsc1) do
    @doc = "Gestion de drapeau"


    ensurable

    newparam(:name) do
     desc "Chemin absolue vers un fichier"
    end

    newproperty(:activer) do
     desc "activer ou desactiver le drapeau"
     newvalue(:true)
     newvalue(:false)
    end

end
