--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	EventHandling.lua - Defines event handlers.
]]--
do
    --[[ Global References ]]--
    local pairs = pairs;
    local mathrandom = math.random;
    local CloseGossip = CloseGossip;
    local UnitName = UnitName;
    local PlaySound = PlaySound;
    local IG_QUEST_LIST_CLOSE = SOUNDKIT.IG_QUEST_LIST_CLOSE;
    local IG_QUEST_LIST_COMPLETE = SOUNDKIT.IG_QUEST_LIST_COMPLETE;
    local IG_QUEST_LOG_ABANDON_QUEST = SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST;


    --[[ Constants ]]--
    local Contractor = _Contractor;
    local Events = {};

    --[[
        Contractor.Events.OnLoad
        Invoked when the add-on is loaded.
    ]]--
    Events.OnLoad = function()
        -- Register new events.
        Events.frame:RegisterEvent("GOSSIP_SHOW");
        Events.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        Events.frame:RegisterEvent("PLAYER_CHANGED_TARGET"); -- Debug.

        -- Initiate persistant storage table.
        if not ContractorData then ContractorData = {}; end
        Contractor.StoredData = ContractorData;

        -- Setup indexing.
        if ContractorData.ActiveContracts then
            local index = Contractor.Index;
            for masterID, contract in pairs(ContractorData.ActiveContracts) do
                for i = 1, #contract.targets do
                    local target = contract.targets[i];
                    local entry = index[target];

                    if entry then
                        entry[#entry][masterID] = true;
                    else
                        index[target] = { [masterID] = true };
                    end
                end
            end
        end

        -- Hook Gossip handling functions.
        Events._GossipTitleButton_OnClick = GossipTitleButton_OnClick;
        GossipTitleButton_OnClick = Events.Hook_GossipTitleButton_OnClick;
    end

    --[[
        Contractor.Events.OnEvent
        Used to handle events from an event frame.
        @param {Frame} eventFrame Event handling frame.
        @param {string} event Identifier for the event type.
        @param {...} Extra parameters for the event.
    ]]--
    Events.OnEvent = function(eventFrame, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...;
            if addonName == Contractor.AddonName then
                Events.frame:UnregisterEvent("ADDON_LOADED");
                Events.OnLoad();
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Display load message in chat.
            local version = GetAddOnMetadata(Contractor.AddonName, "Version");
            Contractor.UI.AddChatMessage(Contractor.VersionLoaded:format(Contractor.AddonName, version));

            -- Unregister the event.
            eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, subEvent, _, _, _, _, _, guid = ...;
            if subEvent == "UNIT_DIED" then
                Contractor.RegisterCreatureDeath(Contractor.GetCreatureIDFromGUID(guid));
            end
        elseif event == "GOSSIP_SHOW" then
            Events.OnGossip();
        elseif event == "PLAYER_CHANGED_TARGET" then
            -- ToDo: Remove, this is for debug.
            local targetID = Contractor.GetCreatureID("target");
            if targetID > 0 then
                Contractor.UI.AddChatMessage("Target ID: " .. targetID);
            end
        end
    end

    --[[
        Contractor.Events.OnGossip
        Invoked when the GOSSIP_SHOW event is triggered.
    ]]--
    Events.OnGossip = function()
        local masterID = Contractor.GetCreatureID("npc");
        local active = Contractor.GetActiveContract(masterID);

        if active then
            if Contractor.IsContractComplete(active) then
                Contractor.UI.AddGossipOption(Contractor.GossipContractComplete, "ContractorFinalize");
            else
                Contractor.UI.AddGossipOption(Contractor.GossipContractProgress, "ContractorProgress");
                Contractor.UI.AddGossipOption(Contractor.GossipContractAbandon, "ContractorAbandon");
            end
        else
            local available = Contractor.GetAvailableContracts(masterID);
            if available and #available > 0 then
                Contractor.UI.AddGossipOption(Contractor.GossipLookingForContract, "ContractorAccept");
            end
        end
    end

    --[[
        Contractor.Events.OnCommand
        Invoke when a Contractor chat command is executed.
    ]]--
    Events.OnCommand = function(msg, editbox)
        Contractor.UI.ShowContractPane();
    end

    --[[
        Contractor.Events.Hook_GossipTitleButton_OnClick
        External hook used for intercepting gossip title button clicks.
        @param {Frame} self Gossip frame.
        @param {Button} button Clicked button.
    ]]--
    Events.Hook_GossipTitleButton_OnClick = function(self, button)
        if self.type == "ContractorAccept" then
            local masterID = Contractor.GetCreatureID("npc");
            local contracts = Contractor.GetAvailableContracts(masterID);
            local contract = contracts[mathrandom(#contracts)];

            Contractor.SetActiveContract(masterID, contract, UnitName("npc"));

            local fullText = contract.textFull:format(contract.count);
            Contractor.UI.ClearGossipOptions();
            Contractor.UI.SetGossipText(Contractor.GossipAcceptedText:format(fullText));
            Contractor.UI.AddGossipOption(Contractor.GossipContractOkay, "ContractorClose", "GossipGossipIcon");

            PlaySound(IG_QUEST_LIST_CLOSE);
        elseif self.type == "ContractorProgress" then
            local masterID = Contractor.GetCreatureID("npc");
            local active = Contractor.GetActiveContract(masterID);

            Contractor.UI.ClearGossipOptions();
            Contractor.UI.SetGossipText(Contractor.GossipProgressText:format(active.progress, active.textShort:lower(), active.count));
            Contractor.UI.AddGossipOption(Contractor.GossipContractOkay, "ContractorClose", "GossipGossipIcon");
        elseif self.type == "ContractorFinalize" then
            local masterID = Contractor.GetCreatureID("npc");

            Contractor.HandleReward();
            Contractor.AbandonActiveContract(masterID);

            PlaySound(IG_QUEST_LIST_COMPLETE);
            CloseGossip();
        elseif self.type == "ContractorAbandon" then
            Contractor.UI.ClearGossipOptions();
            Contractor.UI.SetGossipText(Contractor.GossipAbandonConfirm);

            Contractor.UI.AddGossipOption(Contractor.GossipAbandonConfirmOption, "ContractorAbandonConfirm", "GossipGossipIcon");
            Contractor.UI.AddGossipOption(Contractor.GossipAbandonAbortOption, "ContractorClose", "GossipGossipIcon");
        elseif self.type == "ContractorAbandonConfirm" then
            Contractor.AbandonActiveContract(Contractor.GetCreatureID("npc"));
            PlaySound(IG_QUEST_LOG_ABANDON_QUEST);
            CloseGossip();
        elseif self.type == "ContractorClose" then
            CloseGossip();
        else
            Events._GossipTitleButton_OnClick(self, button);
        end
    end

    --[[ Event Handler ]]--
    Events.frame = CreateFrame("FRAME");
    Events.frame:RegisterEvent("ADDON_LOADED");
    Events.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
    Events.frame:SetScript("OnEvent", Events.OnEvent);

    --[[ Register Commands ]]--
    SLASH_CONTRACTOR1, SLASH_CONTRACTOR2, SLASH_CONTRACTOR3 = "/contractor", "/contracts", "/contract";
    SlashCmdList["CONTRACTOR"] = Events.OnCommand;

    -- Add event table into the add-on table.
    Contractor.Events = Events;
end
