Hypervisor.Protected = { 
    Data   = { }
}

function Hypervisor.Protected:New( Type )
    if ( isfunction( Type ) ) then 
        Type = getfenv( Type )
    end

    Hypervisor:Print( 'Inserted data "%s" into the protected table.', tostring( Type ) )

    table.insert( self.Data, Type )
end

function Hypervisor.Protected:Clear( Type )
    Hypervisor:Print( 'Attempting removal of data "%s" from the protected table.', tostring( Type ) )
    
    for k,v in pairs( self.Data ) do 
        if ( Type == v ) then 
            table.remove( self.Data, k )
                    
            Hypervisor:Print( 'Removed data at %i/%i of the protected table.', k, #self.Data )
        end
    end
end

function Hypervisor:IsProtected( Type, Sources )
    if ( isfunction( Type ) ) then 
        Type = getfenv( Type )
    end

    for k,v in pairs( self.Protected.Data ) do 
        if ( Type == v ) then 
            return true
        end
    end

    return false
end

Hypervisor.Protected:New( Hypervisor.Protected.New )