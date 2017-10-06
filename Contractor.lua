--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contractor.lua - Contains all of the add-on code.
]]--
do
    --[[ Constants ]]--
    local ADDON_NAME = 'Contractor';
    local SUCCESS_COLOUR = CreateColor(0.5803, 1, 0);
    local ERROR_COLOUR = CreateColor(1, 0.5215, 0);

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
        Contractor_OnEvent
        Used to handle events from an event frame.
        @param {Frame} self Event handling frame.
        @param {string} event Identifier for the event type.
        @param {...} Extra parameters for the event.
    ]]--
    local function Contractor_OnEvent(self, event, ...)
        if event == 'ADDON_LOADED' then
            local addonName = ...;
            if addonName == ADDON_NAME then
                -- ToDo: Do stuff here.
                self:UnregisterEvent('ADDON_LOADED');
            end
        elseif event == 'PLAYER_ENTERING_WORLD' then
            -- Display load message in chat.
            local version = GetAddOnMetadata(ADDON_NAME, 'Version');
            Contractor_AddChatMessage(ADDON_NAME .. ' v' .. version .. ' has been loaded!');

            -- Unregister the event.
            self:UnregisterEvent('PLAYER_ENTERING_WORLD');
        end
    end

    --[[
        Contractor_GetCreatureID
        Obtain the NPC ID for a given target.
        @param {string} target UnitID to get the ID for.
        @return {number} ID of the unit or zero.
    ]]--
    local function Contractor_GetCreatureID(target)
        local guid = UnitGUID(target);
        local id = guid:find('^Creature-%d+-%d+-%d+-(%d+)-%x+'); -- Creature-0-3109-0-7307-1327-0000568AF2

        return id or 0;
    end

    --[[ Event Handler ]]--
    local eventFrame = CreateFrame('FRAME');
    eventFrame:RegisterEvent('ADDON_LOADED');
    eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD');
    eventFrame:SetScript('OnEvent', Contractor_OnEvent);
end
