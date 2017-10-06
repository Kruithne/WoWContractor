--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contractor.lua - Defines the core API for the add-on.
]]--
do
    --[[ Global References ]]--
    local pairs = pairs;

    --[[ Add-on Container ]]--
    local Contractor = {
        Strings = {},
        staticContracts = {},
    };

    --[[ Strings Router ]]--
    setmetatable(Contractor, { __index = function(t, k) return t.Strings[k]; end });

    --[[
        Contractor.ApplyLocalization
        Apply a table of localization strings to the add-on.
        @param {table} locale Contains locale strings.
    ]]--
    Contractor.ApplyLocalization = function(locale)
        local strings = Contractor.Strings;
        for key, value in pairs(locale) do
            strings[key] = value;
        end
    end

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
