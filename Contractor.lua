--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contractor.lua - Contains all of the add-on code.
]]--
do
    --[[ Constants ]]--
    local ADDON_NAME = "Contractor";
    local SUCCESS_COLOUR = CreateColor(0.5803, 1, 0);
    local ERROR_COLOUR = CreateColor(1, 0.5215, 0);
    local PREDEFINED_CONTRACTS = {};

    --[[
        Contractor_SetPredefinedTable
        Set the table to source pre-defined contracts from.
        @param {table} tbl New table filled with contract data.
    ]]--
    function Contractor_SetPredefinedTable(tbl)
        PREDEFINED_CONTRACTS = tbl;
    end

    --[[
        Contractor_AddChatMessage
        Send a formatted chat message from this add-on.
        @param {string} msg Text to print into chat.
        @param {ColorMixin} [colour] Text colour, defaults to SUCCESS_COLOUR.
    ]]--
    local function Contractor_AddChatMessage(msg, colour)
        DEFAULT_CHAT_FRAME:AddMessage((colour or SUCCESS_COLOUR):WrapTextInColorCode(msg));
    end

    --[[
        Contractor_GetCreatureID
        Obtain the NPC ID for a given target.
        @param {string} target UnitID to get the ID for.
        @return {number} ID of the unit or zero.
    ]]--
    local function Contractor_GetCreatureID(target)
        local guid = UnitGUID(target);
        local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+");

        return id and tonumber(id) or 0;
    end

    --[[
        Contractor_OnGossip
        Invoked when the GOSSIP_SHOW event is triggered.
        @param {Frame} self Event handling frame.
    ]]--
    local function Contractor_OnGossip(self)
        local targetID = Contractor_GetCreatureID("npc");
        local contract = PREDEFINED_CONTRACTS[targetID];

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
        Contractor_OnLoad
        Invoked when the add-on is loaded.
        @param {Frame} self Event handling frame.
    ]]--
    local function Contractor_OnLoad(self)
        -- Unregister ADDON_LOADED event.
        self:UnregisterEvent("ADDON_LOADED");

        -- Register new events.
        self:RegisterEvent("GOSSIP_SHOW");
        self:RegisterEvent("PLAYER_CHANGED_TARGET"); -- Debug.

        -- Initiate persistant storage table.
        if not ContractorData then
            ContractorData = {};
        end

        -- Hook Gossip handling functions.
        local _GossipTitleButton_OnClick = GossipTitleButton_OnClick;
        GossipTitleButton_OnClick = function(self, button)
            if self.type == "RoleplayContract" then
                Contractor_AddChatMessage("Clicked");
            else
                _GossipTitleButton_OnClick(self, button);
            end
        end
    end

    --[[
        Contractor_OnEvent
        Used to handle events from an event frame.
        @param {Frame} self Event handling frame.
        @param {string} event Identifier for the event type.
        @param {...} Extra parameters for the event.
    ]]--
    local function Contractor_OnEvent(self, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...;
            if addonName == ADDON_NAME then
                Contractor_OnLoad(self);
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Display load message in chat.
            local version = GetAddOnMetadata(ADDON_NAME, "Version");
            Contractor_AddChatMessage(ADDON_NAME .. " v" .. version .. " has been loaded!");

            -- Unregister the event.
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        elseif event == "GOSSIP_SHOW" then
            Contractor_OnGossip(self);
        elseif event == "PLAYER_CHANGED_TARGET" then
            -- ToDo: Remove, this is for debug.
            local targetID = Contractor_GetCreatureID("target");
            if targetID > 0 then
                Contractor_AddChatMessage("Target ID: " .. targetID);
            end
        end
    end

    --[[ Event Handler ]]--
    local eventFrame = CreateFrame('FRAME');
    eventFrame:RegisterEvent('ADDON_LOADED');
    eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD');
    eventFrame:SetScript('OnEvent', Contractor_OnEvent);
end
