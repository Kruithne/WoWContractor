--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contractor.lua - Defines the core API for the add-on.
]]--
do
    --[[ Add-on Container ]]--
    local Contractor = {
        ADDON_NAME = "Contractor",
        staticContracts = {},
    };

    --[[
        _Contractor.GetCreatureID
        Obtain the NPC ID for a given target.
        @param {string} target UnitID to get the ID for.
        @return {number} ID of the unit or zero.
    ]]--
    Contractor.GetCreatureID = function(target)
        local guid = UnitGUID(target);
        local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+");

        return id and tonumber(id) or 0;
    end

    -- Expose add-on container to the global environment.
    _G["_Contractor"] = Contractor;
end
