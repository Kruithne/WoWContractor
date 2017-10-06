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
        StaticContracts = {},
        StaticContractMasters = {},
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
        Contractor.GetCreatureID
        Obtain the NPC ID for a given target.
        @param {string} target UnitID to get the ID for.
        @return {number} ID of the unit or zero.
    ]]--
    Contractor.GetCreatureID = function(target)
        local guid = UnitGUID(target);
        local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+");

        return id and tonumber(id) or 0;
    end

    --[[
        Contractor.AddStaticContract
        Add a static contract for an NPC.
        @param {number} npcID ID of the NPC to give the contract.
        @param {string} contractID Unique identifier for the contract.
        @param {table} contract Data defining the contract.
    ]]--
    Contractor.AddStaticContract = function(npcID, contractID, contract)
        Contractor.StaticContracts[contractID] = contract;

        local master = Contractor.StaticContractMasters[npcID];
        if master then
            master[#master] = contractID;
        else
            Contract.StaticContractMasters[npcID] = {contractID};
        end
    end

    -- Expose add-on container to the global environment.
    _G["_Contractor"] = Contractor;
end
