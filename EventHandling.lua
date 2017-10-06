--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	EventHandling.lua - Defines event handlers.
]]--
do
    --[[ Constants ]]--
    local Contractor = _Contractor;
    local Events = {};

    --[[
        _Contractor.Events.OnLoad
        Invoked when the add-on is loaded.
    ]]--
    Events.OnLoad = function()
        -- Unregister ADDON_LOADED event.
        Events.frame:UnregisterEvent("ADDON_LOADED");

        -- Register new events.
        Events.frame:RegisterEvent("GOSSIP_SHOW");
        Events.frame:RegisterEvent("PLAYER_CHANGED_TARGET"); -- Debug.

        -- Initiate persistant storage table.
        if not ContractorData then
            ContractorData = {};
        end

        -- Hook Gossip handling functions.
        Events._GossipTitleButton_OnClick = GossipTitleButton_OnClick;
        GossipTitleButton_OnClick = Events.Hook_GossipTitleButton_OnClick;
    end

    --[[
        _Contractor.Events.OnEvent
        Used to handle events from an event frame.
        @param {Frame} eventFrame Event handling frame.
        @param {string} event Identifier for the event type.
        @param {...} Extra parameters for the event.
    ]]--
    Events._OnEvent = function(eventFrame, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...;
            if addonName == Contractor.ADDON_NAME then
                Events.OnLoad();
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Display load message in chat.
            local version = GetAddOnMetadata(Contractor.ADDON_NAME, "Version");
            Contractor.UI.AddChatMessage(Contractor.ADDON_NAME .. " v" .. version .. " has been loaded!");

            -- Unregister the event.
            eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
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
        _Contractor.Events.OnGossip
        Invoked when the GOSSIP_SHOW event is triggered.
    ]]--
    _C.OnGossip = function()
        local targetID = Contractor:GetCreatureID("npc");
        local contract = Contractor.staticContracts[targetID];

        if contract then
            local frame, index;

            for i = 1, NUMGOSSIPBUTTONS do
                frame = _G["GossipTitleButton" .. i];
                if not frame:IsVisible() then
                    index = i;
                    break;
                end
            end

            frame:SetText("I'm looking for a contract.");
            GossipResize(frame);
            frame:SetID(index);
            frame.type = "RoleplayContract";

            local icon = _G[frame:GetName() .. "GossipIcon"];
            icon:SetTexture("Interface\\GossipFrame\\BattleMasterGossipIcon");
            icon:SetVertexColor(1, 1, 1, 1);

            GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
            frame:Show();
        end
    end

    --[[
        _Contractor.Events.Hook_GossipTitleButton_OnClick
        External hook used for intercepting gossip title button clicks.
        @param {Frame} self Gossip frame.
        @param {Button} button Clicked button.
    ]]--
    Events.Hook_GossipTitleButton_OnClick = function(self, button)
        if self.type == "RoleplayContract" then
            Contractor.UI.AddChatMessage("Clicked.");
        else
            Events._GossipTitleButton_OnClick(self, button);
        end
    end

    --[[ Event Handler ]]--
    Events.frame = CreateFrame("FRAME");
    Events.frame:RegisterEvent("ADDON_LOADED");
    Events.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
    Events.frame:SetScript("OnEvent", _C._OnEvent);

    -- Add event table into the add-on table.
    Contractor.Events = Events;
end
