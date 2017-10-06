--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	UI.lua - Defines UI related functions.
]]--
do
    --[[ Constants ]]--
    local Contractor = _Contractor;
    local UI = {
        Colours = {
            Success = CreateColor(0.5803, 1, 0),
            Error = CreateColor(1, 0.5215, 0)
        }
    };

    --[[
        _Contractor.UI.AddChatMessage
        Send a formatted chat message from this add-on.
        @param {string} msg Text to print into chat.
        @param {ColorMixin} [colour] Text colour, defaults to SUCCESS_COLOUR.
    ]]--
    UI.AddChatMessage = function(msg, colour)
        DEFAULT_CHAT_FRAME:AddMessage((colour or UI.Colours.Success):WrapTextInColorCode(msg));
    end

    -- Add UI table to the add-on table.
    Contractor.UI = UI;
end
