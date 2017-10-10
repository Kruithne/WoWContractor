--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	UI.lua - Defines UI related functions.
]]--
do
    --[[ Global References ]]--
    local NUMGOSSIPBUTTONS = NUMGOSSIPBUTTONS;
    local GossipResize = GossipResize;
    local GossipFrame = GossipFrame;
    local GossipGreetingText = GossipGreetingText;
    local UIErrorsFrame = UIErrorsFrame;
    local ERR_QUEST_ADD_FOUND_SII = ERR_QUEST_ADD_FOUND_SII;
    local YELLOW_FONT_COLOR = YELLOW_FONT_COLOR;
    local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset;
    local HybridScrollFrame_Update = HybridScrollFrame_Update;
    local ToggleDropDownMenu = ToggleDropDownMenu;
    local GetCursorPosition = GetCursorPosition;

    --[[ Constants ]]--
    local BUTTON_HEIGHT = 84;
    local Contractor = _Contractor;
    local UI = {
        Colours = {
            Success = CreateColor(0.5803, 1, 0),
            Error = CreateColor(1, 0.5215, 0)
        }
    };

    --[[
        Contractor.UI.AddChatMessage
        Send a formatted chat message from this add-on.
        @param {string} msg Text to print into chat.
        @param {ColorMixin} [colour] Text colour, defaults to SUCCESS_COLOUR.
    ]]--
    UI.AddChatMessage = function(msg, colour)
        DEFAULT_CHAT_FRAME:AddMessage((colour or UI.Colours.Success):WrapTextInColorCode(msg));
    end

    --[[
        Contractor.UI.ClearGossipOptions
        Remove all gossip options currently available.
    ]]--
    UI.ClearGossipOptions = function()
        for i = 1, NUMGOSSIPBUTTONS do
            _G["GossipTitleButton" .. i]:Hide();
        end
    end

    --[[
        Contractor.UI.SetGossipText
        Set the current gossip text.
        @param {string} text
    ]]--
    UI.SetGossipText = function(text)
        GossipGreetingText:SetText(text);
    end

    --[[
        Contractor.UI.AddGossipOption
        Add a custom gossip option to the gossip frame.
        @param {string} text Gossip option text.
        @param {string} value Button value.
        @param {string} [gossipIcon] Optional icon to use.
    ]]--
    UI.AddGossipOption = function(text, value, gossipIcon)
        -- Take no action if the GossipFrame isn't shown.
        if not GossipFrame:IsVisible() then
            return;
        end

        -- Iterate through all gossip buttons and find the
        -- first one that isn't being used currently.
        local frame, index;
        for i = 1, NUMGOSSIPBUTTONS do
            frame = _G["GossipTitleButton" .. i];
            if not frame:IsVisible() then
                index = i;
                break;
            end
        end

        frame:SetText(text);
        GossipResize(frame);
        frame:SetID(index);
        frame.type = value;

        -- Apply the icon we want.
        local icon = _G[frame:GetName() .. "GossipIcon"];
        icon:SetTexture("Interface\\GossipFrame\\" .. (gossipIcon or "BattleMasterGossipIcon"));
        icon:SetVertexColor(1, 1, 1, 1);

        GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
        frame:Show();
    end

    --[[
        Contractor.UI.ShowCriteraUpdate
        Show a quest critera update message.
        @param {string} description Objective description.
        @param {number} fulfilled How many of the objective is done?
        @param {number} required How many of the objective is needed in total?
    ]]--
    UI.ShowCriteraUpdate = function(description, fulfilled, required)
        UIErrorsFrame:AddMessage(ERR_QUEST_ADD_FOUND_SII:format(description, fulfilled, required), YELLOW_FONT_COLOR:GetRGB());
    end

    --[[
        Contractor.UI.UpdateContractPane
        Updates the contents of the contract pane.
    ]]--
    UI.UpdateContractPane = function()
        local contracts = Contractor.GetActiveContracts();
        local scrollFrame = ContractorFrameViewContainer;
        local offset = HybridScrollFrame_GetOffset(scrollFrame);
        local buttons = scrollFrame.buttons;
        local numButtons = #buttons;
        local numContracts = #contracts;
        local button, index;

        for i = 1, numButtons do
            local button = buttons[i];
            index = offset + i;

            if index <= numContracts then
                local contract = contracts[index];
                button.title:SetText(contract.title);
                button.comment:SetText(ERR_QUEST_ADD_FOUND_SII:format(contract.textShort, contract.progress, contract.count));
                button.master:SetText(contract.masterName);

                button:SetHeight(50);

                button:Show();
                button.index = index;
            else
                button:Hide();
            end
        end

        HybridScrollFrame_Update(scrollFrame, numContracts * BUTTON_HEIGHT, numButtons * BUTTON_HEIGHT);
    end

    --[[
        Contractor.UI.OnContractButtonClick
        Invoked when a player clicks on a button in the contract list.
    ]]--
    UI.OnContractButtonClick = function()
        local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition();
        ToggleDropDownMenu(nil, nil, ContractorFrameDropDown, "UIParent", x / uiScale, y / uiScale);
    end

    --[[
        Contractor.UI.OnContractMenuOpen
        Invoked when a contract context menu is opened.
    ]]--
    UI.OnContractMenuOpen = function(frame, level, menuList)
        -- ToDo: Add proper options. Localize.
        UIDropDownMenu_AddButton({ text = "Hello poppet." }, level);
    end

    --[[
        Contractor.UI.ShowContractPane
        Show the contract management frame.
    ]]--
    UI.ShowContractPane = function()
        if not UI.hasRenderedBefore then
            ContractorFrameTitleText:SetText(Contractor.FrameContracts);
            SetPortraitToTexture(ContractorFrameIcon, "Interface\\ICONS\\Achievement_Ashran_Tourofduty");

            local container = ContractorFrameViewContainer;
            HybridScrollFrame_CreateButtons(container, "ContractorButtonTemplate", 0, 0);

            ContractorFrameViewButton:SetText(Contractor.UIButtonText);

            UIDropDownMenu_Initialize(ContractorFrameDropDown, UI.OnContractMenuOpen, "MENU");
            for _, button in next, container.buttons do
                button:SetScript("OnClick", UI.OnContractButtonClick);
            end

            local scrollFrame = ContractorFrameViewContainerScrollBar;
            scrollFrame.Show = function(self)
                container:SetWidth(304);
                for _, button in next, container.buttons do button:SetWidth(301); end
                getmetatable(self).__index.Show(self);
            end

            scrollFrame.Hide = function(self)
                container:SetWidth(320);
                for _, button in next, container.buttons do button:SetWidth(320); end
                getmetatable(self).__index.Hide(self);
            end

            UI.hasRenderedBefore = true;
        end

        UI.UpdateContractPane();
        ContractorFrame:Show();
    end

    -- Add UI table to the add-on table.
    Contractor.UI = UI;
end
