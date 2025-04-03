AddCSLuaFile( )

local Hypervisor = { }

-- =============================================================================
-- Setup table copier.
-- =============================================================================

function Hypervisor:Copy( Table, Lookup, Index )
	-- Ported almost completely from: lua/includes/extensions/table.lua.

    Index = Index or _G

    if ( not Table ) then 
        return 
    end 

	local Copy = { }
    
    Lookup = Lookup or { }

    -- Copy over the metatable.
	Index.setmetatable( Copy, Index.debug.getmetatable( Table ) )

	for i, v in Index.pairs( Table ) do
		if ( not Index.istable( v ) ) then 
			Copy[ i ] = v
            continue
        end

        Lookup[ Table ] = Copy
        
        if ( Lookup[ v ] ) then
            Copy[ i ] = Lookup[ v ]
        else
            Copy[ i ] = self:Copy( v, Lookup )
        end
	end

	return Copy
end

-- =============================================================================
-- Restore colors.
-- =============================================================================

function Hypervisor:Color( R, G, B, A )
    return {
        r = R,
        g = G,
        b = B,
        a = A
    }
end

-- =============================================================================
-- Setup basic functionality.
-- =============================================================================

Hypervisor.Globals = Hypervisor:Copy( _G )

Hypervisor.Colors = {
    [ 'Main' ] = Hypervisor:Color( 255, 114, 255 ),

    [ 'White' ]     = Hypervisor:Color( 255, 255, 255 ),
    [ 'Black' ]     = Hypervisor:Color( 0, 0, 0 ),
    [ 'Gray' ]      = Hypervisor:Color( 30, 30, 30 ),
    [ 'Invisible' ] = Hypervisor:Color( 0, 0, 0, 0 ),

    [ 'Light Gray' ] = Hypervisor:Color( 80, 80, 80 ),
    [ 'Dark Gray' ]  = Hypervisor:Color( 18, 18, 18 ),
    [ 'Cyan' ]       = Hypervisor:Color( 60, 180, 225 ),
    [ 'Purple' ]     = Hypervisor:Color( 133, 97, 136 ),

    [ 'Red' ]   = Hypervisor:Color( 255, 0, 0 ),
    [ 'Green' ] = Hypervisor:Color( 0, 255, 0 ),
    [ 'Blue' ]  = Hypervisor:Color( 0, 0, 255 ) 
}

function Hypervisor:PrintEx( Color, Message, ... )
    Color = Color or self.Colors[ 'Main' ]

    self.Globals.MsgC( 
        Color, 
        '[ Constellation ] ', 
        self.Colors[ 'White' ],
        self.Globals.string.format( Message, ... ),
        '\n'
    )
end

function Hypervisor:Print( Message, ... )
    return self:PrintEx( nil, Message, ... )
end

function Hypervisor:Execute( Code, Environment )
    local Compiled = CompileString( Code, 'Hypervisor' )

    if ( not Compiled ) then 
        return false
    end

    if ( Environment ) then 
        setfenv( Compiled, Environment )
    end

    Compiled( )
end

-- =============================================================================
-- Create root environment.
-- =============================================================================

Hypervisor.Environment = Hypervisor.Globals.setmetatable( {
    _G  = _G,
    __G = Hypervisor.Globals,

    Hypervisor = Hypervisor
}, {
    __index = Hypervisor.Globals
} )

function Hypervisor:Include( Directory )
    local Handle = file.Open( Directory, 'rb', 'LUA' )

    if ( not Handle ) then 
        return false
    end

    self:Execute( Handle:Read( Handle:Size( ) ), self.Environment )

    Handle:Close( )
end

-- =============================================================================
-- Include our handlers.
-- =============================================================================

Hypervisor:Include( 'hypervisor/security/protected.lua' )