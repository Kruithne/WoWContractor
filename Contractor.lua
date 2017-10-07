--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contractor.lua - Defines the core API for the add-on.
]]--
do
    --[[ Global References ]]--
    local pairs = pairs;
    local tonumber = tonumber;
    local mathrandom = math.random;
    local UnitGUID = UnitGUID;
    local UnitName = UnitName;
    local UnitIsPlayer = UnitIsPlayer;
    local UnitFullName = UnitFullName;

    --[[ Add-on Container ]]--
    local Contractor = {
        Strings = {},
        StaticContracts = {},
        Index = {},
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
        return Contractor.GetCreatureIDFromGUID(UnitGUID(target));
    end

    --[[
        Contractor.GetCreatureIDFromGUID
        Convert a creature GUID into an entry ID.
        @param {string} guid GUID of the creature.
        @return {number} Creature ID.
    ]]--
    Contractor.GetCreatureIDFromGUID = function(guid)
        local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+");
        return id and tonumber(id) or 0;
    end

    --[[
        Contractor.RegisterCreatureDeath
        Tally a death of a creature, updating related contracts.
        @param {number} npcID ID of the NPC that died.
    ]]--
    Contractor.RegisterCreatureDeath = function(npcID)
        local entry = Contractor.Index[npcID];
        if entry then
            for masterID, _ in pairs(entry) do
                Contractor.IncrementContractProgress(Contractor.GetActiveContract(masterID));
            end
        end
    end

    --[[
        Contractor.IncrementContractProgress
        Increment the progress of a contract.
        @param {table} contract Contract to update.
    ]]--
    Contractor.IncrementContractProgress = function(contract)
        if contract and not Contractor.IsContractComplete(contract) then
            contract.progress = contract.progress + 1;
            Contractor.UI.ShowCriteraUpdate(contract.textShort, contract.progress, contract.count);
        end
    end

    --[[
        Contractor.GetAvailableContracts
        Obtain all contracts an NPC has available.
        @param {number} npcID ID of the NPC.
        @return {table} Table of contracts.
    ]]--
    Contractor.GetAvailableContracts = function(npcID)
        return Contractor.StaticContracts[npcID] or nil;
    end

    --[[
        Contractor.GetActiveContract
        Get the active contract for an NPC or player.
        @param {number|string} masterID Player name or npcID.
        @return {table} Contract data.
    ]]--
    Contractor.GetActiveContract = function(masterID)
        local store = Contractor.StoredData.ActiveContracts;
        return store and store[masterID] or nil;
    end

    --[[
        Contractor.SetActiveContract
        Set the active contract for a contract master.
        @param {string|number} masterID NPC or player the contract came from.
        @param {table} contractData Data regarding the contract.
        @return {boolean} True if activated successfully.
    ]]--
    Contractor.SetActiveContract = function(masterID, contractData)
        local contract = { progress = 0 };
        for key, value in pairs(contractData) do
            contract[key] = value;
        end

        -- Store contract entry.
        if Contractor.StoredData.ActiveContracts then
            Contractor.StoredData.ActiveContracts[masterID] = contract;
        else
            Contractor.StoredData.ActiveContracts = { [masterID] = contract };
        end

        -- Apply indexing.
        local index = Contractor.Index;
        for i = 1, #contract.targets do
            local targetID = contract.targets[i];
            local entry = index[targetID];

            if entry then
                entry[#entry + 1] = masterID;
            else
                index[targetID] = { masterID };
            end
        end
    end

    --[[
        Contractor.AbandonActiveContract
        Abandon the active contract for a contract master.
        @param {string|number} masterID NPC or player the contract came from.
    ]]--
    Contractor.AbandonActiveContract = function(masterID)
        -- Remove contract entry.
        if Contractor.StoredData.ActiveContracts then
            Contractor.StoredData.ActiveContracts[masterID] = nil;
        end

        -- Remove any indexing.
        local index = Contractor.Index;
        for targetID, masters in pairs(index) do
            if masters[masterID] then
                masters[masterID] = nil;
            end
        end
    end

    --[[
        Contractor.HandleReward
        Present the player with a reward.
    ]]--
    Contractor.HandleReward = function()
        local chat = ChatTypeInfo["MONSTER_EMOTE"];
        DEFAULT_CHAT_FRAME:AddMessage(Contractor.RewardEmote:format(UnitName("npc"), mathrandom(2, 20)), chat.r, chat.g, chat.b);
    end

    --[[
        Contractor.IsContractComplete
        Check if the given contract is complete.
        @param {table} contract Active contract.
        @return {boolean} True if complete.
    ]]--
    Contractor.IsContractComplete = function(contract)
        return contract.progress >= contract.count;
    end

    --[[
        Contractor.AddStaticContract
        Add a static contract for an NPC.
        @param {number} npcID ID of the NPC to give the contract.
        @param {table} contract Data defining the contract.
    ]]--
    Contractor.AddStaticContract = function(npcID, contract)
        local master = Contractor.StaticContracts[npcID];
        if master then
            master[#master+1] = contract;
        else
            Contractor.StaticContracts[npcID] = {contract};
        end
    end

    -- Expose add-on container to the global environment.
    _G["_Contractor"] = Contractor;
end
