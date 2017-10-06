--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contractor.lua - Contains all of the add-on code.
]]--
do
    --[[ Add-on Container ]]--
    local _C = {
        ADDON_NAME = "Contractor",
        SUCCESS_COLOUR = CreateColor(0.5803, 1, 0),
        ERROR_COLOUR = CreateColor(1, 0.5215, 0),
        staticContracts = {},
    };

    --[[
        _Contractor.AddChatMessage
        Send a formatted chat message from this add-on.
        @param {table} self Reference to the add-on table.
        @param {string} msg Text to print into chat.
        @param {ColorMixin} [colour] Text colour, defaults to SUCCESS_COLOUR.
    ]]--
    _C.AddChatMessage = function(self, msg, colour)
        DEFAULT_CHAT_FRAME:AddMessage((colour or self.SUCCESS_COLOUR):WrapTextInColorCode(msg));
    end

    --[[
        _Contractor.GetCreatureID
        Obtain the NPC ID for a given target.
        @param {table} self Reference to the add-on table.
        @param {string} target UnitID to get the ID for.
        @return {number} ID of the unit or zero.
    ]]--
    _C.GetCreatureID = function(self, target)
        local guid = UnitGUID(target);
        local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+");

        return id and tonumber(id) or 0;
    end

    --[[
        _Contractor.OnGossip
        Invoked when the GOSSIP_SHOW event is triggered.
        @param {table} self Reference to the add-on table.
    ]]--
    _C.OnGossip = function(self)
        local targetID = self:GetCreatureID("npc");
        local contract = self.staticContracts[targetID];

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
        _Contractor.Hook_GossipTitleButton_OnClick
        External hook used for intercepting gossip title button clicks.
        @param {Frame} self Gossip frame.
        @param {Button} button Clicked button.
    ]]--
    _C.Hook_GossipTitleButton_OnClick = function(self, button)
        if self.type == "RoleplayContract" then
            _C:AddChatMessage("Clicked.");
        else
            self._GossipTitleButton_OnClick(self, button);
        end
    end

    --[[
        _Contractor.OnLoad
        Invoked when the add-on is loaded.
        @param {table} self Reference to the add-on table.
        @param {Frame} eventFrame Event handling frame.
    ]]--
    _C.OnLoad = function(self, eventFrame)
        -- Unregister ADDON_LOADED event.
        eventFrame:UnregisterEvent("ADDON_LOADED");

        -- Register new events.
        eventFrame:RegisterEvent("GOSSIP_SHOW");
        eventFrame:RegisterEvent("PLAYER_CHANGED_TARGET"); -- Debug.

        -- Initiate persistant storage table.
        if not ContractorData then
            ContractorData = {};
        end

        -- Hook Gossip handling functions.
        self._GossipTitleButton_OnClick = GossipTitleButton_OnClick;
        GossipTitleButton_OnClick = self.Hook_GossipTitleButton_OnClick;
    end

    --[[
        _Contractor.OnEvent
        Used to handle events from an event frame.
        @param {table} self Reference to the add-on table.
        @param {Frame} eventFrame Event handling frame.
        @param {string} event Identifier for the event type.
        @param {...} Extra parameters for the event.
    ]]--
    _C.OnEvent = function(self, eventFrame, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...;
            if addonName == self.ADDON_NAME then
                self:OnLoad(eventFrame);
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Display load message in chat.
            local version = GetAddOnMetadata(self.ADDON_NAME, "Version");
            self:AddChatMessage(self.ADDON_NAME .. " v" .. version .. " has been loaded!");

            -- Unregister the event.
            eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
        elseif event == "GOSSIP_SHOW" then
            self:OnGossip();
        elseif event == "PLAYER_CHANGED_TARGET" then
            -- ToDo: Remove, this is for debug.
            local targetID = self:GetCreatureID("target");
            if targetID > 0 then
                self:AddChatMessage("Target ID: " .. targetID);
            end
        end
    end

    --[[ Event Handler ]]--
    _C.eventFrame = CreateFrame("FRAME");
    _C.eventFrame:RegisterEvent("ADDON_LOADED");
    _C.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    _C.eventFrame:SetScript("OnEvent", _C.OnEvent);

    -- Expose add-on container to the global environment.
    _G["_Contractor"] = Contractor;
end
